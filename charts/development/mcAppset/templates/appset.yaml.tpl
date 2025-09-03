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
      elements:
        - cluster: engineering-dev
          namespace: engineering-dev
          project: default
          url: https://kubernetes.default.svc
          config:
            # Target Revision to use
            targetRevision: HEAD
            # Git repo where the config is stored
            repoUrl: example.com
            # Path to the config file in the repo
            path: configs/enineering-dev
          helm:
            # Target revision to use
            targetRevision: HEAD
            # Can be git or chart
            type: "chart"
            # The chart name in case of type chart, otherwise the path to the folder
            # containing the chart
            path: "engineering-chart"

      # template:
      #   metadata: {}
      #   spec:
      #     project: "default"
      #     source:
      #       targetRevision: HEAD
      #       repoURL: https://github.com/argoproj/argo-cd.git
      #       # New path value is generated here:
      #       path: 'applicationset/examples/template-override/{{ .nameNormalized }}-override'
      #     destination: {}

  template:
    metadata:
      name: `'{{ .nameNormalized }}-guestbook'`
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