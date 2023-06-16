# CP4D Install
## Automated Script
My most recent experience is with using daffy scripts that are automated through techzone tiles
## Deployment Environments
### Techzone & VPN set-up step-by-step 
[Techzone CP4D daffy environment](https://techzone.ibm.com/collection/PakInstaller#tab-2)
> Note: For whatever reason, this environment tends to run slowly. In order to reduce latency for users, I highly suggest following these steps

1. When provisioning the above environment, make sure you set the VPN tile to 'enabled'
2. Download/install WireGuard VPN software
3. Download VPN config as found on your Techzone reservation page
4. User your WireGuard client to "import tunnel from file" and import your config file
5. Deactivate your Cisco VPN and disable your DNS Proxy & Transparent Proxy in your General Settings
6. Activate your WireGuard VPN
7. If multiple users necessary, you can create multiple VPN peers within your Guacamole Virtual Desktop by navigating to pfSense https://192.168.252.1/index.php via your firefox browser on your Remote Desktop. From there, sign in with your guacamole credentials (hard to find, but located on techzone reservation page). After that, go to the WireGuard VPN menu and create peers for the different users that will need to access the project. Each user/peer will need a seperate config file with a private key and a seperate IP address.  
    1. ‘Add Peer’
    2. Select tun_wg0 tunnel
    3. Enter description (User2 for e.g.)
    4. Generate WireGuard public and private key for each user. $ wg genkey | tee privatekey | wg pubkey > publickey
    5. Set AllowedIPs to unique address 192.168.253.x/32
    6. Click save
    7. Replace Address and Private Key in your downloaded WireGuard config
