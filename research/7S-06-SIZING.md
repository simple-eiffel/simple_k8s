# 7S-06: SIZING - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Implementation Size

### Core Classes

| Component | Lines | Files |
|-----------|-------|-------|
| SIMPLE_K8S | ~235 | 1 |
| K8S_CLIENT | ~660 | 1 |
| K8S_HTTP | ~200 | 1 |
| K8S_CONFIG | ~200 | 1 |
| K8S_AUTH | ~150 | 1 |
| K8S_ERROR | ~100 | 1 |

### Resource Classes

| Component | Lines | Files |
|-----------|-------|-------|
| K8S_POD | ~100 | 1 |
| K8S_DEPLOYMENT | ~100 | 1 |
| K8S_SERVICE | ~100 | 1 |
| K8S_NAMESPACE | ~50 | 1 |
| K8S_CONFIGMAP | ~50 | 1 |
| K8S_SECRET | ~50 | 1 |

### Spec Classes

| Component | Lines | Files |
|-----------|-------|-------|
| POD_SPEC | ~150 | 1 |
| DEPLOYMENT_SPEC | ~150 | 1 |
| SERVICE_SPEC | ~150 | 1 |
| SERVICE_PORT | ~80 | 1 |

### Utility Classes

| Component | Lines | Files |
|-----------|-------|-------|
| KUBECTL_QUICK | ~200 | 1 |
| K8S_CI_QUICK | ~100 | 1 |
| MANIFEST_BUILDER | ~150 | 1 |

### Total

| Category | Classes | LOC |
|----------|---------|-----|
| Core | 6 | ~1,545 |
| Resources | 6 | ~550 |
| Specs | 4 | ~530 |
| Utilities | 3 | ~450 |
| **Total** | **19** | **~3,075** |
