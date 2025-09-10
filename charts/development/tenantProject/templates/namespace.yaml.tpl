kind: Namespace
apiVersion: v1
metadata:
  name: {{ .Release.Namespace | quote }}
  annotations:
    # Argocd wave
    argocd.argoproj.io/sync-wave: "-10"
    # Helm hook annotations to prevent deletion
    {{- if .Values.tenantProject.hookNamespace }}
    helm.sh/hook: pre-install,post-delete
    helm.sh/hook-weight: "-8"
    helm.sh/hook-delete-policy: hook-failed
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookFailed
    {{- end }}
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
