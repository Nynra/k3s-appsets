{{ if .Values.enabled }}{{ if .Values.metallb.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metallb
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  destination:
    namespace: metallb-system
    server: {{ .Values.global.server }}
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-metallb
      targetRevision: {{ .Values.metallb-app.targetRevision }}
      path: chart
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.metallb-app.configPath }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
      - ServerSideApply=false
{{- end }}{{- end }}