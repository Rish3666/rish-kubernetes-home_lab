# Contributing

This is a personal homelab repo, but contributions, ideas, and forks are welcome.

## Getting Started

1. Fork the repo
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/rish-kubernetes-home_lab.git
   ```
3. Create a branch:
   ```bash
   git checkout -b your-feature-name
   ```

## What Works Well Here

- **Helm values / charts** — `apps/`, `charts/`, `databases/`
- **Shell scripts** — `scripts/`, `apps/minecraft-docker/`
- **Docs** — `docs/`, `README.md`

## Before You Submit

- Test your changes locally (K3s cluster or Docker Compose)
- If you add a new app, include a `README.md` or inline docs explaining how to deploy it
- Keep secrets out of commits — use env vars or external secrets

## Pull Request

1. Push your branch:
   ```bash
   git push origin your-feature-name
   ```
2. Open a PR against `main` with a short description of what changed and why

## Code Style

- Helm values: 2-space indentation
- Shell scripts: `set -eu`, `sh` shebang, no bashisms unless necessary
- Keep it simple — this is a homelab, not a production platform
