{{- if .Values.enabled }}{{- if .Values.externalSecrets.enabled }}{{- if .Values.externalSecrets.certificates.enabled }}
{{- range .Values.externalSecrets.certificates.certificates }}
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
    {{- if $.Values.externalSecrets.stores.enabled }}
    name: "{{ $.Values.tenantProject.name }}-cert-store"
    {{- end }}
    {{- end }}
  target:
    creationPolicy: Owner
  data:
    - secretKey: tls.crt
      remoteRef:
        key: {{ .remoteName | quote }}
        property: "tls_crt"
        conversionStrategy: Default	
        decodingStrategy: None
        metadataPolicy: None
    - secretKey: tls.key
      remoteRef:
        key: {{ .remoteName | quote }}
        property: "tls_key"
        conversionStrategy: Default	
        decodingStrategy: None
        metadataPolicy: None
{{- end }}
{{- end }}{{- end }}{{- end }}