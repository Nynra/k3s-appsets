{{ if .Values.enabled }}{{ if .Values.eks-app.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: eks
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "3"
spec:
  destination:
    namespace: external-secrets
    server: {{ .Values.global.server }}
  project: {{ .Values.global.project }}
  sources:
    - repoURL: {{ .Values.global.config.repoURL }}
      targetRevision: {{ .Values.global.config.targetRevision }}
      ref: gitopsDir
    - repoURL: https://github.com/Nynra/k3s-1password
      targetRevision: {{ .Values.eks-app.targetRevision }}
      path: chart
      helm:
        valueFiles:
          - $gitopsDir/{{ .Values.eks-app.configPath }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
  ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      name: externalsecret-validate
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      name: secretstore-validate
{{- end }}{{- end }}