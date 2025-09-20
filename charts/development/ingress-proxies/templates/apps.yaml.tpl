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
    namespace: {{ .name }}-proxy
    server: {{ $.Values.argocd.server | quote }}
  project: {{ $.Values.argocd.project | quote }}
  source:
    repoURL: https://github.com/Nynra/k3s-charts
    targetRevision: HEAD
    path: charts/development/ingress-proxy
    helm:
      valuesObject:
        networkPolicy:
          enabled: {{ $.Values.networkPolicy.enabled }}
          ingress:
            traefikNamespace: {{ $.Values.networkPolicy.ingress.traefikNamespace | quote }}
            traefikPodSelector: {{ toYaml $.Values.networkPolicy.ingress.traefikPodSelector | nindent 12 }}
        ingress:
          enabled: {{ .ingress.enabled | default true }}
          url: {{ .ingress.url | quote }}
          entrypoint: {{ .ingress.entrypoint | default $.Values.defaults.ingress.entrypoint | quote }}
          {{ if .middleware }}
          middlewares: 
            - name: {{ .ingress.middleware.name | quote }}
              namespace: {{ .ingress.middleware.namespace | quote }}
          {{ else }}
          middlewares: 
            - name: {{ $.Values.defaults.ingress.middleware.name | quote }}
              namespace: {{ $.Values.defaults.ingress.middleware.namespace | quote }}
          {{ end }}
          cert:
            reflectedSecret:
              enabled: {{ $.Values.cert.reflectedSecret.enabled }}
              originName: {{ $.Values.cert.reflectedSecret.originName | quote }}
              originNamespace: {{ $.Values.cert.reflectedSecret.originNamespace | quote }}
        dnsRecord:
          enabled: false 
        externalServer:
          tls:
            enabled: {{ .backend.tls.enabled }}
            skipVerify: {{ .backend.tls.skipVerify | default $.Values.defaults.backend.tls.skipVerify }}
          url: {{ .backend.url | quote }}
          port: {{ .backend.port }}
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
