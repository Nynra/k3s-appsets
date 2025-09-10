# k3s-project

This chart is a simple tool to create and manage tenant projects in a k3s-cluster. Each tentant project is linked to an argoCD project and can contain multiple namespaces. The goal is to provide a tenant environment that is isolated from other tenants, while still allowing for shared resources like ingress and monitoring.

## Features

### Implemented

### Planned

- [ ] ArgoCD Project:
  - [ ] Allow or deny resources in the tenant namespaces

- [ ] Networking:
  - [ ] Allow or deny access to other tenant namespaces (network policies)

- [ ] External Secrets:
  - [ ] Optional 1password connect server to provide the tenant access to their own vaults
  - [ ] Optional secrets operator scoped to only reconsile the tenant namespaces connected to its own connect server
  - [ ] Optional secret stores provided by a cluster scoped secrets operator (should only allow access to tenant vault managed by cluster scoped connect server)

simplified version of:
<https://github.com/startxfr/helm-repository/tree/master/charts/project>

<https://www.suse.com/c/rancher_blog/k3s-network-policy/>
