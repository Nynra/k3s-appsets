{{ if .Values.enabled }}{{ if .Values.monitoring-app.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k3s-monitoring
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "7"
spec:
  destination:
    namespace: monitoring
    server: {{ .Values.global.server }}
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-monitoring
      targetRevision: {{ .Values.monitoring-app.targetRevision }}
      path: chart
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.monitoring-app.configPath }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
{{- end }}{{- end }}