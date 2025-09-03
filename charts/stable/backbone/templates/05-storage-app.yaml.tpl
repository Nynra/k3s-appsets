{{ if .Values.enabled }}{{ if .Values.longhorn-app.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: longhorn
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "6"
spec:
  destination:
    namespace: longhorn-system
    server: {{ .Values.global.server }}
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-storage
      targetRevision: {{ .Values.longhorn-app.targetRevision }}
      path: chart
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.longhorn-app.configPath }}
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
  ignoreDifferences:
    - group: apiextensions.k8s.io/v1
      name: trafficsplits.split.smi-spec.io
      kind: CustomResourceDefinition
      jsonPointers:
        - /spec/preserveUnknownFields
    - group: apiextensions.k8s.io/v1
      name: trafficsplits.split.smi-spec.io
      kind: CustomResourceDefinition
      jsonPointers:
        - /spec/preserveUnknownFields
{{ end }}{{ end }}