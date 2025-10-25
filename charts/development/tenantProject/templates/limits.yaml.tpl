{{- if .Values.enabled }}{{- if .Values.limits.enabled }}
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
  namespace: {{ .Release.Name }}-resources
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    {{- if .Values.global.commonAnnotations }}
    # Global annotations
    {{- toYaml .Values.global.commonAnnotations | nindent 4 }}
    {{- end }}
  labels:
    tenancy.io/tenant: {{ .Values.tenantProject.name | quote }}
    {{- if .Values.global.commonLabels }}
    # Global labels
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  {{- toYaml .Values.limits.rules | nindent 2 }}
{{- end }}{{- end }}