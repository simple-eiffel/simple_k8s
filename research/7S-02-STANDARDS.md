# 7S-02: STANDARDS - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Applicable Standards

### Kubernetes API

- **Kubernetes API Reference**: Official API specification
- **API Versioning**: v1 (core), apps/v1 (deployments)

### Authentication

- **kubeconfig**: Standard config file format
- **In-cluster auth**: Service account token mounting
- **Bearer token**: Authorization header

## API Versions Supported

### Core API (v1)

| Resource | Path | Support |
|----------|------|---------|
| Pod | /api/v1/namespaces/{ns}/pods | Full CRUD |
| Service | /api/v1/namespaces/{ns}/services | Full CRUD |
| Namespace | /api/v1/namespaces | List, Get |
| ConfigMap | /api/v1/namespaces/{ns}/configmaps | List, Get |
| Secret | /api/v1/namespaces/{ns}/secrets | List, Get |

### Apps API (apps/v1)

| Resource | Path | Support |
|----------|------|---------|
| Deployment | /apis/apps/v1/namespaces/{ns}/deployments | Full CRUD + Scale |

## Standards Compliance

### Authentication Methods

| Method | Support |
|--------|---------|
| kubeconfig file | Yes |
| In-cluster token | Yes |
| Bearer token | Yes |
| Client certificates | Via kubeconfig |
| OIDC | No |

### API Conventions

| Convention | Compliance |
|------------|------------|
| JSON responses | Full |
| HTTP methods | GET, POST, PUT, PATCH, DELETE |
| Status codes | Handled |
| Error format | Parsed |
