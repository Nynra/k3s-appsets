{{- if .Values.enabled -}}
---
kind: Namespace
apiVersion: v1
metadata:
  name: {{ .Release.Name }}-applications
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
    {{- if .Values.global.commonAnnotations }}
    # Global annotations
    {{- toYaml .Values.global.commonAnnotations | nindent 4 }}
    {{- end }}
  labels:
    tenancy.io/tenant-project: {{ .Values.tenantProject.name | quote }}
    {{- if .Values.global.commonLabels }}
    # Global labels
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
---
kind: Namespace
apiVersion: v1
metadata:
  name: {{ .Release.Namespace }}-resources
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
    {{- if .Values.global.commonAnnotations }}
    # Global annotations
    {{- toYaml .Values.global.commonAnnotations | nindent 4 }}
    {{- end }}
  labels:
    tenancy.io/tenant-project: {{ .Values.tenantProject.name | quote }}
    {{- if .Values.global.commonLabels }}
    # Global labels
    {{- toYaml .Values.global.commonLabels | nindent 4 }}
    {{- end }}
{{- end }}
