{{ if .Values.enabled }}{{ if .Values.argocd.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-argocd
      path: chart
      targetRevision: {{ .Values.argocd-app.targetRevision }}
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.argocd-app.configPath }}
  destination:
    server: {{ .Values.global.server }}
    # Do not change this namespace unless you know what you are doing!
    # ArgoCD must already be installed in this namespace
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
{{- end }}{{- end }}