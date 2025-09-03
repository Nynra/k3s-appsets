{{ if .Values.enabled }}{{ if .Values.gatekeeper-app.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gatekeeper
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  destination:
    namespace: gatekeeper-system
    server: {{ .Values.global.server }}
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-cluster-policies
      targetRevision: {{ .Values.gatekeeper-app.targetRevision }}
      path: chart
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.gatekeeper-app.configPath }}
{{ end }}{{ end }}