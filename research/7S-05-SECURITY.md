# 7S-05: SECURITY - simple_k8s

**Library**: simple_k8s
**Date**: 2026-01-23
**Status**: BACKWASH (reverse-engineered from implementation)

## Security Considerations

### Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Credential exposure | High | Config file permissions |
| Token theft | High | In-cluster mount security |
| API injection | Medium | Parameter validation |
| TLS bypass | High | HTTPS required |
| Privilege escalation | High | K8s RBAC |

### Authentication Security

#### kubeconfig

- Reads from standard locations
- Respects file permissions
- Token/cert stored in memory only during use

#### In-Cluster

- Uses mounted service account
- Token from /var/run/secrets
- Namespace from /var/run/secrets

### API Security

| Protection | Status |
|------------|--------|
| HTTPS only | Enforced by K8s |
| Bearer token auth | Implemented |
| Certificate auth | Via kubeconfig |
| Request validation | Basic |

## Security Best Practices

### Do

1. Use minimal RBAC permissions
2. Rotate service account tokens
3. Audit API operations
4. Use namespaces for isolation

### Don't

1. Embed tokens in code
2. Use cluster-admin unnecessarily
3. Skip TLS verification (even in dev)
4. Store kubeconfig in version control

## Security Limitations

- No built-in audit logging
- No request signing
- Trust K8s API server TLS
