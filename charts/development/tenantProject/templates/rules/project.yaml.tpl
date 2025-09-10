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
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: {{ .Values.tenantProject.description | quote }}
  {{ if (empty .Values.tenantProject.sourceRepos) }}
  sourceRepos: []
  {{ else }}
  sourceRepos:
    {{- range .Values.tenantProject.sourceRepos }}
    - {{ . | quote }}
    {{- end }}
  {{ end }}
  destinations:
    - namespace: {{ $tenantNamespace }}
      server: {{ .Values.tenantProject.destinationServer | quote }}
  {{ if (empty .Values.tenantProject.destinationNamespaces) }}
  destinationNamespaces: []
  {{ else }}
  destinationNamespaces:
    {{- range .Values.tenantProject.destinationNamespaces }}
    - {{ . | quote }}
    {{- end }}
  {{ end }}
  {{ if (empty .Values.tenantProject.clusterResourceWhitelist) }}
  clusterResourceWhitelist: []
  {{ else }}
  clusterResourceWhitelist:
    {{- range .Values.tenantProject.clusterResourceWhitelist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  {{ end }}
  {{ if (empty .Values.tenantProject.namespaceResourceBlacklist) }}
  namespaceResourceBlacklist: []
  {{ else }}
  namespaceResourceBlacklist:
    {{- range .Values.tenantProject.namespaceResourceBlacklist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  {{ end }}
  {{ if (empty .Values.tenantProject.namespaceResourceWhitelist) }}
  namespaceResourceWhitelist: []
  {{ else }}
  namespaceResourceWhitelist:
    {{- range .Values.tenantProject.namespaceResourceWhitelist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  {{ end }}
  {{ if or .Values.tenantProject.enableReadOnlyRole (not (empty .Values.tenantProject.roles)) }}
  roles:
    {{- if .Values.tenantProject.enableReadOnlyRole }}
    - name: readonly
      description: Read-only privileges to {{ .Values.tenantProject.name }}
      policies:
      - p, proj:{{ .Values.tenantProject.name }}:read-only, applications, get, {{ .Values.tenantProject.name }}/*, allow
    {{- end }}
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
  {{ else }}
  roles: []
  {{ end }}
  {{ if (empty .Values.tenantProject.syncWindows) }}
  syncWindows: []
  {{ else }}
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
  {{ end }}
  orphanedResources:
    warn: false
{{- end }}{{- end }}
