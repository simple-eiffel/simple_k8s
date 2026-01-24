# 7S-03: SOLUTIONS - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Existing Solutions Comparison

### No Native Eiffel K8s Client

Before simple_k8s, options were:
1. Shell out to kubectl (process overhead)
2. Direct HTTP API calls (complex)
3. No solution (avoid K8s)

### simple_k8s Advantages

| Aspect | Value |
|--------|-------|
| Native Eiffel | Type-safe operations |
| Simple API | kubectl-like interface |
| Auth handling | Automatic kubeconfig |
| Error handling | Structured K8S_ERROR |

## Design Decisions

### Architecture Layers

```
SIMPLE_K8S (facade)
    |
    +-- KUBECTL_QUICK (convenience)
    +-- K8S_CLIENT (API operations)
    +-- K8S_HTTP (HTTP transport)
    +-- K8S_CONFIG (configuration)
    +-- K8S_AUTH (authentication)
```

### Resource Specs

Fluent builders for resources:
- POD_SPEC
- DEPLOYMENT_SPEC
- SERVICE_SPEC
- SERVICE_PORT

### Why HTTP Client Approach?

1. No external library dependencies
2. Full control over requests
3. Easy to extend for new resources
4. Works with simple_http

## Alternative Approaches Considered

1. **kubectl exec**: Process overhead, parsing issues
2. **gRPC client**: Complex, over-engineered
3. **Generated client**: Maintenance burden
