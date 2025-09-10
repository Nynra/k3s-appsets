{{- if .Values.enabled }}{{- if .Values.gitopsApplication.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "{{ .Values.tenantProject.name }}-gitops-orchestrator"
  namespace: {{ .Values.managementProject.namespace | quote }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    # Global annotations
    {{- if .Values.global.commonAnnotations }}
    {{- toYaml .Values.global.commonAnnotations | nindent 4 }}
    {{- end }}
  labels:
    tenancy.io/tenant: {{ .Values.tenantProject.name | quote }}
    # Global labels
    {{- if .Values.global.commonLabels }}
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  project: {{ .Values.managementProject.name | quote }}
  destination:
    server: {{ .Values.tenantProject.destinationServer | quote }}
    namespace: {{ .Release.Namespace | quote }}
  source:
    repoURL: {{ .Values.gitopsApplication.repoURL | quote }}
    targetRevision: {{ .Values.gitopsApplication.targetRevision | quote }}
    path: {{ .Values.gitopsApplication.path | quote }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
{{- end }}{{- end }}