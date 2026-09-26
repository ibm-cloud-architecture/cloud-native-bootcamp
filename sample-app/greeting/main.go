// greeting is the sample service used throughout the Cloud Native Bootcamp labs.
//
// Endpoints:
//
//	/greeting?name=<name>[&delay_ms=<n>]  JSON greeting; delay_ms adds latency (max 5000)
//	/fail                                  always returns HTTP 500 (for alerting exercises)
//	/healthz                               liveness/readiness check
//	/metrics                               Prometheus metrics
//
// Configuration (environment variables):
//
//	GREETING                     message returned by /greeting
//	OTEL_EXPORTER_OTLP_ENDPOINT  enables OpenTelemetry tracing when set, e.g. http://collector:4318
//	OTEL_SERVICE_NAME            service name reported in traces (default "greeting")
package main

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

var (
	logger = slog.New(slog.NewJSONHandler(os.Stdout, nil))
	tracer = otel.Tracer("greeting")

	requests = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "greeting_requests_total",
		Help: "HTTP requests handled, by path and status code.",
	}, []string{"path", "code"})
	duration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "greeting_request_duration_seconds",
		Help:    "HTTP request latency in seconds, by path.",
		Buckets: prometheus.DefBuckets,
	}, []string{"path"})
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	shutdownTracing := setupTracing(ctx)
	defer shutdownTracing()

	message := os.Getenv("GREETING")
	if message == "" {
		message = "Welcome to the Cloud Native Bootcamp!"
	}

	mux := http.NewServeMux()
	mux.Handle("/greeting", instrument("/greeting", greetingHandler(message)))
	mux.Handle("/fail", instrument("/fail", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "simulated failure"})
	}))
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})
	mux.Handle("/metrics", promhttp.Handler())

	server := &http.Server{Addr: ":8080", Handler: mux, ReadHeaderTimeout: 10 * time.Second}
	go func() {
		logger.Info("greeting service listening", "addr", server.Addr)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("server failed", "error", err)
			os.Exit(1)
		}
	}()

	<-ctx.Done()
	logger.Info("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	server.Shutdown(shutdownCtx)
}

func greetingHandler(message string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "World"
		}
		if ms, err := strconv.Atoi(r.URL.Query().Get("delay_ms")); err == nil && ms > 0 {
			slowDown(r.Context(), min(ms, 5000))
		}
		_, span := tracer.Start(r.Context(), "compose greeting")
		span.SetAttributes(attribute.String("greeting.name", name))
		body := map[string]string{"message": message, "name": name}
		span.End()
		writeJSON(w, http.StatusOK, body)
	}
}

// slowDown simulates a slow dependency, recorded as its own span.
func slowDown(ctx context.Context, ms int) {
	_, span := tracer.Start(ctx, "slow dependency")
	defer span.End()
	span.SetAttributes(attribute.Int("delay_ms", ms))
	time.Sleep(time.Duration(ms) * time.Millisecond)
}

// instrument records Prometheus metrics, a trace span and a structured log line per request.
func instrument(path string, next http.HandlerFunc) http.Handler {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w, code: http.StatusOK}
		next(rec, r)
		elapsed := time.Since(start)

		requests.WithLabelValues(path, strconv.Itoa(rec.code)).Inc()
		duration.WithLabelValues(path).Observe(elapsed.Seconds())

		attrs := []any{"method", r.Method, "path", path, "code", rec.code, "duration_ms", elapsed.Milliseconds()}
		if sc := trace.SpanContextFromContext(r.Context()); sc.IsValid() {
			attrs = append(attrs, "trace_id", sc.TraceID().String())
		}
		logger.InfoContext(r.Context(), "request", attrs...)
	})
	return otelhttp.NewHandler(handler, path)
}

type statusRecorder struct {
	http.ResponseWriter
	code int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.code = code
	r.ResponseWriter.WriteHeader(code)
}

func writeJSON(w http.ResponseWriter, code int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(body)
}

// setupTracing sends traces over OTLP/HTTP when OTEL_EXPORTER_OTLP_ENDPOINT is set.
// Without it, tracing stays a no-op and the service runs as before.
func setupTracing(ctx context.Context) func() {
	if os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT") == "" {
		return func() {}
	}
	if os.Getenv("OTEL_SERVICE_NAME") == "" {
		os.Setenv("OTEL_SERVICE_NAME", "greeting")
	}
	exporter, err := otlptracehttp.New(ctx)
	if err != nil {
		logger.Error("tracing disabled: cannot create OTLP exporter", "error", err)
		return func() {}
	}
	res, _ := resource.New(ctx, resource.WithFromEnv(), resource.WithTelemetrySDK())
	provider := sdktrace.NewTracerProvider(sdktrace.WithBatcher(exporter), sdktrace.WithResource(res))
	otel.SetTracerProvider(provider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))
	tracer = otel.Tracer("greeting")
	logger.Info("tracing enabled", "endpoint", os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"))

	return func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		provider.Shutdown(ctx)
	}
}
