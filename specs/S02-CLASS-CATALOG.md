# S02: CLASS CATALOG - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Class Hierarchy

```
SIMPLE_K8S (facade)
    |
    +-- K8S_CLIENT (API operations)
    |       +-- K8S_HTTP (transport)
    |       +-- K8S_AUTH (authentication)
    |
    +-- KUBECTL_QUICK (convenience API)
    |
    +-- K8S_CONFIG (configuration)

K8S_ERROR (error handling)

Resource Specs (builders):
    POD_SPEC
    DEPLOYMENT_SPEC
    SERVICE_SPEC
    SERVICE_PORT
```

## Class Descriptions

### SIMPLE_K8S

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | Main facade |
| Pattern | Facade |
| LOC | ~235 |

### K8S_CLIENT

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | API operations |
| LOC | ~660 |
| Features | 40+ |

**Covers**: Pod, Deployment, Service, Namespace, ConfigMap, Secret operations.

### KUBECTL_QUICK

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | kubectl-like API |
| LOC | ~200 |

### K8S_CONFIG

| Attribute | Value |
|-----------|-------|
| Type | Effective class |
| Role | Configuration parsing |
| LOC | ~200 |

### Spec Classes

| Class | Purpose | LOC |
|-------|---------|-----|
| POD_SPEC | Pod definition | ~150 |
| DEPLOYMENT_SPEC | Deployment definition | ~150 |
| SERVICE_SPEC | Service definition | ~150 |
| SERVICE_PORT | Port mapping | ~80 |

## Class Metrics Summary

| Category | Classes | Total LOC |
|----------|---------|-----------|
| Facade | 1 | 235 |
| Core | 5 | 1,310 |
| Specs | 4 | 530 |
| Utilities | 3 | 450 |
| **Total** | **13** | **~2,525** |
