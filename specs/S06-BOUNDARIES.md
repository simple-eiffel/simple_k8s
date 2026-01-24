# S06: BOUNDARIES - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## System Boundaries

### What simple_k8s IS

- Kubernetes API client
- Pod/Deployment/Service management
- kubeconfig and in-cluster auth
- kubectl-like convenience API
- JSON response handling

### What simple_k8s IS NOT

- Helm client
- CRD manager
- Cluster administrator
- Node manager
- RBAC manager
- Event watcher

## Resource Boundaries

### Fully Supported (CRUD)

- Pods
- Deployments
- Services

### Read-Only

- Namespaces
- ConfigMaps
- Secrets

### Not Supported

- StatefulSets
- DaemonSets
- Jobs/CronJobs
- Ingress
- NetworkPolicy
- PersistentVolumes

## API Boundaries

### Public API

| Class | Access |
|-------|--------|
| SIMPLE_K8S | Full |
| K8S_CLIENT | Via k8s.client |
| KUBECTL_QUICK | Via k8s.kubectl |
| *_SPEC classes | Direct |

### Type References

Available via SIMPLE_K8S for anchored types:
- pod_spec_typeref
- deployment_spec_typeref
- service_spec_typeref
- k8s_error_typeref
- k8s_config_typeref

## Integration Boundaries

### Uses

| Library | Purpose |
|---------|---------|
| simple_http | HTTP client |
| simple_json | JSON parsing |

### Used By

| Potential | Purpose |
|-----------|---------|
| simple_deploy | Deployment tools |
| CI/CD tools | Automation |
