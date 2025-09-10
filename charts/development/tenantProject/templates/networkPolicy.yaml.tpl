{{- if .Values.enabled }}{{- if .Values.networkPolicy.enabled }}{{- if .Values.networkPolicy.additionalRules }}
{{ range .Values.networkPolicy.additionalRules }} 
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: "{{ .id }}-{{ $.Values.tenantProject.name }}-networkpolicy"
  namespace: {{- $.Release.Namespace| quote }}
  labels:
    app.kubernetes.io/name: "{{ .id }}-{{ $.Values.tenantProject.name }}-networkpolicy"
    tenancy.io/tenant: {{ $.Values.tenantProject.name | quote }}
    # Global labels
    {{- if $.Values.global.commonLabels }}
    {{- toYaml $.Values.global.commonLabels | nindent 4 }}
    {{- end }}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    # Global annotations
    {{- if $.Values.global.commonAnnotations }}
    {{- toYaml $.Values.global.commonAnnotations | nindent 4 }}
    {{- end }}
spec: 
  {{- .spec | nindent 2 }}
{{ end }}
{{- end }}{{- end }}{{- end }}