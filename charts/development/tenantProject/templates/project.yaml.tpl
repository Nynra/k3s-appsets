{{- if .Values.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ .Values.tenantProject.name | quote }}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
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
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  sourceRepos:
    {{- range .Values.tenantProject.sourceRepos }}
    - {{ . | quote }}
    {{- end }}
  destinations:
    - namespace: {{ .Release.Name }}-applications
      server: {{ .Values.tenantProject.destinationServer | quote }}
    - namespace: {{ .Release.Name }}-resources
      server: {{ .Values.tenantProject.destinationServer | quote }}
  {{ if not (empty .Values.tenantProject.clusterResourceWhitelist) }}
  clusterResourceWhitelist:
    {{- range .Values.tenantProject.clusterResourceWhitelist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  {{ else }}
  clusterResourceWhitelist: []
  {{ end }}
  {{- if not (empty .Values.tenantProject.namespaceResourceWhitelist) }}
  namespaceResourceWhitelist:
    {{- range .Values.tenantProject.namespaceResourceWhitelist }}
    - group: {{ .group | quote }}
      kind: {{ .kind | quote }}
    {{- end }}
  {{ else }}
  namespaceResourceWhitelist: []
  {{- end }}
  {{- if not (empty .Values.tenantProject.roles) }}
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
  {{- else }}
  roles: {}
  {{- end }}
  {{- if not (empty .Values.tenantProject.syncWindows) }}
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
  {{- end }}
  orphanedResources:
    warn: false
{{- end }}
