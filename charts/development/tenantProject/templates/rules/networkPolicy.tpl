{{- if .Values.enabled }}{{- if .Values.networkPolicy.enabled }}{{- if .Values.networkPolicy.isolateTenant -}}
# Block all incoming traffic
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: "{{ .Release.Namespace }}-deny-by-default"
  annotations:
    argocd.argoproj.io/sync-wave: "1"
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
spec:
  podSelector: 
    matchLabels:
      tenant: {{ .Release.Namespace | quote }}
  ingress: []
---
# Allow all traffic within the same namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: "{{ .Release.Namespace }}-allow-same-namespace"
spec:
  podSelector: 
    matchLabels:
      tenant: {{ .Release.Namespace | quote }}
  ingress:
  - from:
    - podSelector: {}
---
{{- if .Values.networkPolicy.isolateTenant.ingress.allow }}
# Allow the ingress loadbalancer Pods to communicate with all Pods in this namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: "{{ .Release.Namespace }}-allow-all-svclb-ingress"
spec:
  podSelector: 
    matchLabels:
      svccontroller.k3s.cattle.io/svcname: {{ .Values.networkPolicy.isolateTenant.ingress.serviceName | quote }}
  ingress:
  - {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: "{{ .Release.Namespace }}-allow-all-traefik-ingress"
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: traefik
  ingress:
  - {}
  policyTypes:
  - Ingress
---
{{- end }}
{{- if .Values.networkPolicy.isolateTenant.monitoring.allow }}
# Allow the monitoring system Pods to communicate with all Pods in this namespace (to allow scraping the metrics)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: "{{ .Release.Namespace }}-allow-monitoring"
spec:
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: {{ .Values.networkPolicy.isolateTenant.monitoring.namespace | quote }}
  podSelector: {}
  policyTypes:
  - Ingress
---
{{- end }}
{{- end }}{{- end }}{{- end }}
