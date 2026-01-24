# 7S-01: SCOPE - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Problem Domain

Kubernetes API client for Eiffel applications - manage pods, deployments, services, and other K8s resources.

### What Problem Does This Solve?

1. **K8s Integration**: Deploy and manage containers from Eiffel
2. **API Abstraction**: Hide Kubernetes API complexity
3. **Resource Management**: CRUD operations for K8s resources
4. **DevOps Automation**: CI/CD integration

### Target Users

- Eiffel developers deploying to Kubernetes
- DevOps automation in Eiffel
- Eiffel-based deployment tools
- Containerized Eiffel applications

### Use Cases

1. Deploy applications to Kubernetes
2. Scale deployments programmatically
3. Query pod status and logs
4. Manage services and namespaces
5. CI/CD pipeline integration

## Boundaries

### In Scope

- Pod operations (create, get, list, delete, logs)
- Deployment operations (create, scale, delete, rollout)
- Service operations (create, get, list, delete)
- Namespace operations (list, get)
- ConfigMap operations (list, get)
- Secret operations (list, get)
- kubectl-like convenience API
- Kubeconfig and in-cluster auth

### Out of Scope

- Helm chart management
- CRD (Custom Resource Definitions)
- Cluster administration
- Node management
- RBAC management
- Horizontal Pod Autoscaler

## Domain Vocabulary

| Term | Definition |
|------|------------|
| Pod | Smallest deployable unit in K8s |
| Deployment | Manages pod replicas |
| Service | Network endpoint for pods |
| Namespace | Resource isolation boundary |
| ConfigMap | Configuration data storage |
| Secret | Sensitive data storage |
| kubeconfig | K8s client configuration file |
