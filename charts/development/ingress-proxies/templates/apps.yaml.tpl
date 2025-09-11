{{ if .Values.enabled }}
{{ range .Values.proxies }}
{{ if .enabled }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .name }}-proxy
  namespace: {{ $.Values.argocd.namespace | quote }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: {{ .namespace | quote }}
    server: {{ $.Values.argocd.server | quote }}
  project: {{ $.Values.argocd.project | quote }}
  source:
    repoURL: https://github.com/Nynra/k3s-charts
    targetRevision: HEAD
    path: charts/development/ingress-proxy
    helm:
      values: |
        # global:
        #   {{ toYaml $.Values.global | nindent 10 }}
        enabled: true
        ingress:
          enabled: {{ .ingress.enabled | default $.Values.defaults.ingress.enabled | quote }} 
          url: {{ .ingress.url | quote }}
          entrypoint: {{ .ingress.entrypoint | default $.Values.defaults.ingress.entrypoint | quote }}
          middlewares:
            {{ if .ingress.middlewares }}
            {{ toYaml .ingress.middlewares | nindent 12 }}
            {{ else }}{{ if $.Values.defaults.ingress.middlewares }}
            {{ toYaml $.Values.defaults.ingress.middlewares | nindent 12 }}
            {{ end }}{{ end }}
          cert:
            {{ toYaml $.Values.cert | nindent 12 }}
        # DNS record for the backend service
        # dnsRecord:
        #   enabled: {{ .backend.dns.enabled | default false }}
        #   {{ if .backend.dns.ip }}
        #   ip: {{ .backend.dns.ip | quote }}
        #   {{ end }}
        #   {{ if $.Values.defaults.backend.dns.labels }}
        #   labels:
        #     {{ toYaml $.Values.defaults.backend.dns.labels | nindent 14 }}
        #   {{ end }}
        #   {{ if .backend.dns.annotations }}
        #   annotations:
        #     {{ toYaml $.Values.defaults.backend.dns.annotations | nindent 14 }}
        #   {{ end }}
        #   recordTTL: {{ .backend.dns.ttl | default $.Values.defaults.backend.dns.ttl }}
        # Parameters for the external server
        externalServer:
          tls:
            enabled: {{ .backend.tls.enabled | quote }}
            skipVerify: {{ .backend.tls.skipVerify | default $.Values.defaults.backend.tls.skipVerify | quote }}
          # IP address of the external server
          url: {{ .backend.url | quote }}
          port: {{ .backend.port | quote }}
          protocol: {{ .backend.protocol | default $.Values.defaults.backend.protocol | quote }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
{{ end }}
{{ end }}
{{ end }}
