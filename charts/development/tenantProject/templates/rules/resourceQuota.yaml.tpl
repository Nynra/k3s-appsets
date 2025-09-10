{{- if .Values.enabled }}{{- if .Values.quota.enabled }}
kind: ResourceQuota
apiVersion: v1
metadata:
  name: "{{ .Values.tenantProject.name }}-quotas"
  namespace: {{ .Release.Namespace | quote }}
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
  {{- .Values.quota.rules | nindent 2 }}
{{- end }}{{- end }}