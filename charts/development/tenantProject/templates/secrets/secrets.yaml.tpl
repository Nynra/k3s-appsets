{{- if .Values.enabled }}{{- if .Values.externalSecrets.enabled }}{{- if .Values.externalSecrets.secrets.enabled }}
{{- range .Values.externalSecrets.secrets.secrets }}
{{- $remoteSecretName := .remoteName | quote }}
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ .name }}
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
  secretStoreRef:
    kind: "SecretStore"
    {{- if .storeName }}
    name: {{ .storeName | quote }}
    {{- else }}
    name: "{{ $.Values.tenantProject.name }}-secret-store"
    {{- end }}
  target:
    creationPolicy: Owner
  data:
    {{- range .fieldMappings}}
    - secretKey: {{ .secretKey | quote }}
      remoteRef:
        key: {{ $remoteSecretName | quote }}
        property: {{ .remoteField | default "password" | quote }}
        conversionStrategy: Default	
        decodingStrategy: None
        metadataPolicy: None
    {{- end }}
{{- end }}
{{- end }}{{- end }}{{- end }}