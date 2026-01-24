# S01: PROJECT INVENTORY - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Project Overview

| Attribute | Value |
|-----------|-------|
| Library Name | simple_k8s |
| Purpose | Kubernetes API client |
| Phase | Production |
| Void Safety | Full |
| SCOOP Ready | Yes |

## File Inventory

### Main Classes (src/)

| File | Purpose |
|------|---------|
| simple_k8s.e | Main facade |

### Core Classes (src/core/)

| File | Purpose |
|------|---------|
| k8s_client.e | API client operations |
| k8s_http.e | HTTP transport |
| k8s_config.e | Configuration handling |
| k8s_auth.e | Authentication |
| k8s_error.e | Error representation |

### Resource Classes (src/resources/)

| File | Purpose |
|------|---------|
| k8s_pod.e | Pod resource |
| k8s_deployment.e | Deployment resource |
| k8s_service.e | Service resource |
| k8s_namespace.e | Namespace resource |
| k8s_configmap.e | ConfigMap resource |
| k8s_secret.e | Secret resource |

### Spec Classes (src/specs/)

| File | Purpose |
|------|---------|
| pod_spec.e | Pod specification builder |
| deployment_spec.e | Deployment spec builder |
| service_spec.e | Service spec builder |
| service_port.e | Service port definition |

### Utility Classes (src/util/)

| File | Purpose |
|------|---------|
| kubectl_quick.e | kubectl-like convenience |
| k8s_ci_quick.e | CI/CD helpers |
| manifest_builder.e | YAML/JSON manifest builder |

### Test Files

| File | Path | Purpose |
|------|------|---------|
| test_app.e | testing/ | Test root |
| lib_tests.e | testing/ | Test cases |
