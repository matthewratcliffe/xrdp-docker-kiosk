# XRDP Kiosk Cluster

This repository sets up a multi-instance XRDP (Remote Desktop Protocol) kiosk environment using Docker Compose. Each kiosk runs an isolated XFCE-based Linux desktop inside a container, designed for display terminals or remote access setups. A central XRDP gateway exposes the remote desktops for RDP clients via a single port.

## 🧩 Features

- Five independent kiosk containers (`xrdp-kiosk-1` to `xrdp-kiosk-5`)
- Shared environment configuration via `.env` file
- Central XRDP gateway container (`xrdp-kiosk-gateway`) on port `3390`
- Support for SSL certificates via volume mounts
- Organized with custom Docker builds (`./xrdp` and `./xrdp-gateway`)
- Isolated Docker network (`kiosk-rdp`) for inter-container communication

---

## 🚀 Getting Started

### 1. Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Optional: `.env` file for environment variables
- Optional: SSL certificate at `./ssl-certs/<CERT_DIR>/cert.pem`

### 2. Directory Structure

````
.
├── docker-compose.yml
├── .env
├── xrdp/
│ └── Dockerfile
├── xrdp-gateway/
│ └── Dockerfile
└── ssl-certs/
└── default/
└── cert.pem
````

### 3. Build and Run

From the root of the repository:

```bash
docker-compose up --build
```

This will:

- Build the xrdp and xrdp-gateway images from local Dockerfiles.
- Start all containers.
- Map the gateway's RDP port to localhost:3390.

### 4. Access

You can connect to the XRDP gateway using any RDP client:

Host: localhost
Port: 3390

You’ll be routed through the gateway container to individual kiosks (ensure you have session routing logic in place if needed).

### 🔧 Customization

- To change the number of kiosks, duplicate one of the xrdp-kiosk services and adjust the container name.
- To modify desktop behavior or installed apps, edit ./xrdp/Dockerfile.
- The .env file can define runtime environment variables for all containers.
- SSL certificate path can be overridden using CERT_DIR in .env.


## 🔐 Mounting a Certificate to `/tmp/cert.pem` (Optional)

Each kiosk container allows a `.pem` certificate to be available at `/tmp/cert.pem` inside the container.

The certificate is installed into Firefox’s trusted store to avoid security warnings when accessing services secured with your self-signed certificate.

You can mount your local certificate using a Docker volume binding like this:

```yaml
volumes:
  - /path/to/your/cert.pem:/tmp/cert.pem:ro
````

In this setup:
- /path/to/your/cert.pem is the absolute or relative path to your local .pem file.
- /tmp/cert.pem is the target path inside the container.
- ro makes the file read-only to the container.

_Example Using Environment Variable_

The Docker Compose file supports using a variable to specify the certificate directory:

````
volumes:
  - ./ssl-certs/cert.pem:/tmp/cert.pem:ro
````

Directory Structure Example
````
.
├── docker-compose.yml
├── .env               # contains CERT_DIR=site-1
└── ssl-certs/
    ├── default/
    │   └── cert.pem
    └── site-1/
        └── cert.pem
````

This makes it easy to use different certificates per deployment or environment.

### 🧹 Stopping and Cleaning

To stop and remove all containers:
````
docker-compose down
````
To remove built images as well:
````
docker-compose down --rmi all
````

### 🛠️ Troubleshooting

- Ensure your .env file is correctly formatted.
- Check permissions on ssl-certs/ and ensure cert.pem is readable.
- Use docker-compose logs -f for real-time container logs.