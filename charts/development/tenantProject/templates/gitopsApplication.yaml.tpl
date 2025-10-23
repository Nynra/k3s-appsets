{{- if .Values.enabled }}{{- if .Values.gitopsApplication.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "{{ .Values.tenantProject.name }}-gitops-orchestrator"
  namespace: {{ .Release.Namespace }}-applications
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
  project: {{ .Values.managementProjectName | quote }}
  destination:
    server: {{ .Values.tenantProject.destinationServer | quote }}
    namespace: {{ .Release.Namespace }}-applications
  source:
    repoURL: {{ .Values.gitopsApplication.repoURL | quote }}
    targetRevision: {{ .Values.gitopsApplication.targetRevision | quote }}
    path: {{ .Values.gitopsApplication.path | quote }}
  syncPolicy:
    {{- if .Values.gitopsApplication.syncPolicy.enabled }}
    automated:
      prune: {{ .Values.gitopsApplication.syncPolicy.prune }}
      selfHeal: {{ .Values.gitopsApplication.syncPolicy.selfHeal }}
    {{- end }}
    syncOptions:
      - CreateNamespace=false
{{- end }}{{- end }}