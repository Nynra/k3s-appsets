{{ if .Values.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tautulli-app
  namespace: {{ .Values.argoCD.namespace | quote }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  destination:
    namespace: {{ .Release.Name }}-tautulli
    server: https://kubernetes.default.svc
  project: {{ .Values.argoCD.project | quote }}
  source:
    repoURL: https://github.com/Nynra/k3s-charts
    targetRevision: HEAD
    path: charts/incubating/tautulli
    helm:
      valuesObject:
        quota:
          enabled: {{ .Values.quota.enabled }}
        networkPolicy:
          enabled: {{ .Values.networkPolicy.enabled }}
          ingress:
            traefikNamespace: {{ .Values.networkPolicy.traefikNamespace | quote }}
            traefikPodSelector: {{ toYaml .Values.networkPolicy.traefikPodSelector | nindent 14 }}
        dashboard:
          ingressUrl: {{ .Values.tautulli.ingressUrl | quote }}
          middlewares:
            - name: {{ .Values.tautulli.middleware.name | quote }}
              namespace: {{ .Values.tautulli.middleware.namespace | quote }}
          cert:
            reflectedSecret:
              enabled: {{ .Values.cert.reflectedSecret.enabled }}
              originNamespace: {{ .Values.cert.reflectedSecret.originNamespace | quote }}
              originName: {{ .Values.cert.reflectedSecret.originName | quote }}
        tautulli:
          enabled: {{ .Values.tautulli.enabled }}
  syncPolicy:
    {{ if .Values.argoCD.autosync }}
    automated:
      prune: true
      selfHeal: true
    {{ end }}
    syncOptions:
      - CreateNamespace=false
{{ end }}