# Security Policy

## Supported Versions

This is a personal homelab project. Security patches are applied to the `main` branch as needed.

## Reporting a Vulnerability

If you find a security issue, please **do not open a public issue**. Instead, reach out privately:

- Open a GitHub issue with the `security` label
- Or contact the repo owner directly

You should receive a response within a few days. Please include:

- A description of the vulnerability
- Steps to reproduce (if applicable)
- Any suggested fix (optional)

## What to Expect

- Confirmation of receipt within 72 hours
- A fix or mitigation will be applied to `main`
- Credit will be given if you'd like (unless you prefer to remain anonymous)

## Scope

This repo contains infrastructure-as-code for a home Kubernetes cluster.
Sensitive values (passwords, tokens) should never be committed — use environment variables or external secrets instead.
