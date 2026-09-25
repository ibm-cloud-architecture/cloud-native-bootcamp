package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func main() {
	message := os.Getenv("GREETING")
	if message == "" {
		message = "Welcome to the Cloud Native Bootcamp!"
	}

	http.HandleFunc("/greeting", func(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Query().Get("name")
		if name == "" {
			name = "World"
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"message": message,
			"name":    name,
		})
	})
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})

	log.Println("greeting service listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
