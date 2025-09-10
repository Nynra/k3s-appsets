{{- if .Values.enabled }}{{- if .Values.externalSecrets.enabled }}{{- if .Values.externalSecrets.stores.enabled }}
{{- range .Values.externalSecrets.stores.stores }}
{{- if .enabled | default true }}
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: {{ .name | quote }}
  namespace: {{ $.Release.Namespace | quote }}
    annotations:
    argocd.argoproj.io/sync-wave: "1"
    # Global annotations
    {{- if $.Values.global.commonAnnotations }}
    {{- toYaml $.Values.global.commonAnnotations | nindent 4 }}
    {{- end }}
  labels:
    tenancy.io/tenant: {{ $.Values.tenantProject.name | quote }}
    # Global labels
    {{- if $.Values.global.commonLabels }}
    {{- toYaml $.Values.global.commonLabels | nindent 4 }}
    {{- end }}
spec:
  provider:
    onepassword:
      connectHost: http://onepassword-connect:8080
      vaults:
        {{- range .vaults }}
        - name: {{ .name | quote }}
          priority: {{ .priority | quote }}
        {{- end }}
      auth:
        secretRef:
          connectTokenSecretRef:
            name: {{ .connectSecretName | quote }}
            key: token
{{- end }}
{{- end }}
{{- end }}{{- end }}{{- end }}