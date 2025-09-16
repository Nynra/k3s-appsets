{{ if .Values.enabled }}{{ if .Values.homarr.enabled}}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: homarr-app
  namespace: {{ .Values.argoCD.namespace | quote }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "4"
spec:
  destination:
    namespace: {{ .Release.Namespace }}-homarr
    server: https://kubernetes.default.svc
  project: {{ .Values.argoCD.project | quote }}
  source:
    repoURL: https://github.com/Nynra/k3s-charts
    targetRevision: HEAD
    path: charts/development/homarr
    helm:
      values: |
        quota:
          enabled: {{ .Values.quota.enabled }}
        networkPolicy:
          enabled: {{ .Values.networkPolicy.enabled }}
          ingress:
            traefikNamespace: {{ .Values.networkPolicy.traefikNamespace | quote }}
            traefikPodSelector: {{ toYaml .Values.networkPolicy.traefikPodSelector | nindent 14 }}
        dashboard:
          ingressUrl: {{ .Values.homarr.ingressUrl | quote }}
          middlewares:
            - name: {{ .Values.homarr.middleware.name | quote }}
              namespace: {{ .Values.homarr.middleware.namespace | quote }}
          cert:
            reflectedSecret:
              enabled: {{ .Values.cert.reflectedSecret.enabled }}
              originNamespace: {{ .Values.cert.reflectedSecret.originNamespace | quote }}
              originName: {{ .Values.cert.reflectedSecret.originName | quote }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
{{ end }}{{ end }}