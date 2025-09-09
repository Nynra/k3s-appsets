{{- if .Values.enabled }}
{{- range .Values.groups }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "adguard-sync-group-{{ .id }}"
  namespace: 
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: default
  source:
    repoURL: https://github.com/Nynra/k3s-argocd
    path: chart
    targetRevision: HEAD
    helm:
      valueFiles:
        - $gitopsDir/configs/argocd-values.yaml
  destination:
    server: "https://kubernetes.default.svc"
    namespace: argocd
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
  ignoreDifferences:
    # Preventing sync loops with secrets
    - group: ""
      kind: Secret
      name: argocd-secret
      jsonPointers:
        - /data
    # Preventing CRD sync loops
    - group: apiextensions.k8s.io
      kind: CustomResourceDefinition
      name: applications.argoproj.io
      jsonPointers:
        - /status
{{- end }}
{{- end }}
