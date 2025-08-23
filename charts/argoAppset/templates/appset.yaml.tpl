apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: mincraftStack
spec:
  # Enable GO-templating
  # Make sure to enclose all go-templating statement that should be parsed by the application-set
  # in helm literal backticks (``), otherwise the templates will be interpreted by helm during
  # the rendering of the chart causing difficult to debug issues.
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
    - list:
        # List of apps to deploy
        elements:
        {{- range .Values.applications }}
          - name: {{ .name }}
            namespace: {{ .namespace }}
            project: {{ .project }}
            config:
              targetRevision: {{ .config.targetRevision | default "HEAD" }}
              repoUrl: {{ .config.repoURL }}
              path: {{ .config.path }}
            helm:
              targetRevision: {{ .helm.targetRevision | default "HEAD" }}
              type: {{ .helm.type | default "chart" }}
              path: {{ .helm.path }}
        {{- end }}
    - list:
        # List of clusters to deploy to
        # This is used to generate the destination for each app
        elements:
        {{- range .Values.clusters }}
          - cluster: {{ .name }}
            url: {{ .url }}
        {{- end }}
  template:
    metadata:
      name: `'{{ .name }}'`
    spec:
      project: `{{ .project }}`
      sources:
        - repoURL: `{{ .config.repoURL }}`
          targetRevision: `{{ .config.targetRevision }}`
          path: `{{ .config.path }}`
          ref: configDir
        - repoURL: `{{ .helm.repoURL }}`
          targetRevision: `{{ .helm.targetRevision }}`
          `{{- if .helm.type "chart" }}`
          chart: `{{ .helm.path }}`
          `{{- else }}`
          `path: {{.helm.path }}`
          `{{- end }}`
          helm:
            valueFiles:
              - `"configDir/{{ .config.path }}"`
      destination:
        server: `{{ .url }}`
        namespace: `{{ .namespace }}`
      `{{- if .syncPolicy }}`
      syncPolicy:
        # Apply app specific sync policy
        `{{- if .syncPolicy.automated }}`
        automated:
          `{{- if .syncPolicy.automated.prune }}`
          prune: `{{ .syncPolicy.automated.prune }}`
          `{{- else }}`
          prune: true
          `{{- end }}`
          `{{- if .syncPolicy.automated.selfHeal }}`
          selfHeal: `{{ .syncPolicy.automated.selfHeal }}`
          `{{- else }}`
          selfHeal: true
          `{{- end }}`
        `{{- else }}`
        # Apply default sync policy
        automated:
          prune: true
          selfHeal: true
        `{{- end }}`
        `{{- if .syncPolicy.syncOptions }}`
        syncOptions:
          `{{- range .syncPolicy.syncOptions }}`
          - `{{ . }}`
          `{{- end }}`
        `{{- end }}`
      `{{- end }}`
    `{{- if .ignoreDifferences }}`
    ignoreDifferences:
      `{{- range .ignoreDifferences }}`
      - group: `{{ .group }}`
        kind: `{{ .kind }}`
        name: `{{ .name }}`
        jsonPointers:
          `{{- range .jsonPointers }}`
          - `{{ . }}`
          {{- end }}
      `{{- end }}`
    `{{- end }}`