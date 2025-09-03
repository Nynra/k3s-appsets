{{ if .Values.enabled }}{{ if .Values.auth-app.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: authentication-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "7"
spec:
  destination:
    namespace: authentik
    server: {{ .Values.global.server }}
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-authentik
      targetRevision: {{ .Values.auth-app.targetRevision }}
      path: chart
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.auth-app.configPath }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
{{- end }}{{- end }}