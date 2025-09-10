kind: Namespace
apiVersion: v1
metadata:
  name: {{ .Release.Namespace | quote }}
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
    {{- if .Values.tenantProject.hookNamespace }}
    # Helm hook annotations to prevent deletion
    helm.sh/hook: pre-install,post-delete
    helm.sh/hook-weight: "-8"
    helm.sh/hook-delete-policy: hook-failed
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookFailed
    {{- end }}
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
