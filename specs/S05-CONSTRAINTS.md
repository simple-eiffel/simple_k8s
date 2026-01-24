# S05: CONSTRAINTS - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## API Version Constraints

### Core API (v1)

| Resource | API Version |
|----------|-------------|
| Pod | v1 |
| Service | v1 |
| Namespace | v1 |
| ConfigMap | v1 |
| Secret | v1 |

### Apps API

| Resource | API Version |
|----------|-------------|
| Deployment | apps/v1 |

## Resource Name Constraints

### Kubernetes Naming Rules

| Constraint | Value |
|------------|-------|
| Max length | 253 characters |
| Pattern | [a-z0-9]([-a-z0-9]*[a-z0-9])? |
| Start/end | Alphanumeric |
| No uppercase | Enforced by K8s |

### Namespace Constraints

| Constraint | Value |
|------------|-------|
| Default | "default" |
| System | "kube-system" |
| Max length | 63 characters |

## Authentication Constraints

### kubeconfig Locations

1. KUBECONFIG environment variable
2. ~/.kube/config
3. Explicit path via make_from_file

### In-Cluster Paths

| Resource | Path |
|----------|------|
| Token | /var/run/secrets/kubernetes.io/serviceaccount/token |
| Namespace | /var/run/secrets/kubernetes.io/serviceaccount/namespace |
| CA cert | /var/run/secrets/kubernetes.io/serviceaccount/ca.crt |

## Operation Constraints

### Replicas

| Constraint | Value |
|------------|-------|
| Minimum | 0 |
| Maximum | K8s dependent |

### Resource Quotas

Limited by cluster configuration (not library).
