{{- if .Values.enabled }}{{- if .Values.externalSecrets.enabled }}{{- if .Values.externalSecrets.eksApplication.enabled }}
# app-1password-connect.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .Values.externalSecrets.eksApplication.name | quote }}
  namespace: {{ .Values.managementProject.namespace | quote }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
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
  destination:
    namespace: {{ .Release.Namespace | quote }}
    server: {{ .Values.tenantProject.destinationServer | quote }}
  project: {{ .Values.tenantProject.name | quote }}
  source:
    repoURL: https://github.com/Nynra/k3s-1password
    targetRevision: {{ .Values.externalSecrets.eksApplication.targetRevision }}
    path: chart
    helm:
      values: |
        enabled: {{ .Values.externalSecrets.eksApplication.enabled | quote }}
        enableReflector: false
        enableConnect: {{ .Values.externalSecrets.eksApplication.connect.enabled | quote }}
        enableEksOperator: {{ .Values.externalSecrets.eksApplication.operator.enabled | quote }}

        connect:
          connect:
            credentialsName: {{ .Values.externalSecrets.eksApplication.connect.credentials.name | quote }}
            credentialsKey: {{ .Values.externalSecrets.eksApplication.connect.credentials.key | quote }}
            api:
              serviceMonitor:
                enabled: {{ .Values.externalSecrets.eksApplication.enableServiceMonitor | quote }}
        
        external-secrets:
          createOperator: true
          installCRDs: false
          scopedNamespace: {{ .Release.Namespace | quote }}
          scopedRBAC: true
          processClusterExternalSecret: false
          processClusterPushSecret: false
          processClusterStore: false
          processPushSecret: {{ .Values.externalSecrets.eksApplication.allowPushSecret | quote }}

          serviceMonitor:
            enabled: {{ .Values.externalSecrets.eksApplication.enableServiceMonitor | quote }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
  ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      name: externalsecret-validate
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      name: secretstore-validate
{{- end }}{{- end }}{{- end }}