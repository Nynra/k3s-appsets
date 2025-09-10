{{- if .Values.enabled }}{{- if .Values.tenantProject.enabled }}
{{- $tenantNamespace := .Release.Namespace | quote }}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ .Values.tenantProject.name | quote }}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    {{-  if .Values.tenantProject.hookProject }}
    helm.sh/hook: pre-install,post-delete
    helm.sh/hook-weight: "-10"
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
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: {{ .Values.tenantProject.description | quote }}
  sourceRepos:
    {{- range .Values.tenantProject.sourceRepos }}
    - {{ . | quote }}
    {{- end }}
  destinations:
    - namespace: {{ $tenantNamespace }}
      server: {{ .Values.tenantProject.destinationServer | quote }}
  clusterResourceWhitelist:
    {{- range .Values.tenantProject.clusterResourceWhitelist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  namespaceResourceBlacklist:
    {{- range .Values.tenantProject.namespaceResourceBlacklist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  namespaceResourceWhitelist:
    {{- range .Values.tenantProject.namespaceResourceWhitelist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  roles:
    {{- range .Values.tenantProject.roles }}
    - name: {{ .name | quote }}
      description: {{ .description | quote }}
      policies:
        {{- range .policies }}
        - {{ . | quote }}
        {{- end }}
      {{- if .groups}}
      groups:
        {{- range .groups }}
        - {{ . | quote }}
        {{- end }}
      {{- end }}
    {{- end }}
  syncWindows:
    {{- range .Values.tenantProject.syncWindows }}
    - kind: {{ .kind | quote }}
      schedule: {{ .schedule | quote }}
      duration: {{ .duration | quote }}
      applications:
        {{- range .applications }}
        - {{ . | quote }}
        {{- end }}
      manualSync: {{ .manualSync | default false }}
    {{- end }}
  orphanedResources:
    warn: false
{{- end }}{{- end }}
