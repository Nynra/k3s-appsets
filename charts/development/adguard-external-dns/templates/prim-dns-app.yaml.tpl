{{ if .Values.enabled }}{{ if .Values.primDNS.enabled }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .Release.Name }}-prim-dns-app
  namespace: {{ .Values.argocd.namespace | quote }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: {{ .Release.Name }}-prim-dns
    server: {{ .Values.argocd.server | quote }}
  project: {{ .Values.argocd.project | quote }}
  source:
    repoURL: https://github.com/Nynra/k3s-charts
    targetRevision: HEAD
    path: charts/development/adguard-home
    helm:
      valuesObject:
        networkPolicy:
          enabled: {{ .Values.networkPolicy.enabled }}
          ingress:
            traefikNamespace: {{ .Values.networkPolicy.ingress.traefikNamespace | quote }}
            traefikPodSelector: {{ toYaml .Values.networkPolicy.ingress.traefikPodSelector | nindent 12 }}
        dashboard:
          enabled: {{ .Values.primDNS.dashboard.enabled }}
          url: {{ .Values.primDNS.dashboard.url | quote }}
          entrypoint: {{ .Values.primDNS.dashboard.entrypoint | quote }}
          middlewares: 
            - name: {{ .Values.primDNS.dashboard.middleware.name | quote }}
              namespace: {{ .Values.primDNS.dashboard.middleware.namespace | quote }}
          cert:
            reflectedSecret:
              enabled: {{ $.Values.cert.reflectedSecret.enabled }}
              originName: {{ $.Values.cert.reflectedSecret.originName | quote }}
              originNamespace: {{ $.Values.cert.reflectedSecret.originNamespace | quote }}
        adguard-home:
          enabled: {{ .Values.primDNS.enableDeps }}
          service:
            main:
              type: {{ .Values.primDNS.service.type | quote }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
{{ end }}
{{ end }}
