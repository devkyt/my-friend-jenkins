{{- define "jenkins.name" -}}
{{ .Values.app.name | default "jenkins" | quote }}
{{- end -}}

{{- define "jenkins.namespace" -}}
{{ .Values.app.namespace | default "jenkins-ci" | quote }}
{{- end -}}


{{- define "jenkins.commonLabels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Values.app.name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{- define "jenkins.server.selectorLabels" -}}
{{- with .Values.server.labels }}
{{- toYaml . }}
{{- end }}
app: jenkins-server
{{- end -}}


{{- define "jenkins.getImage" -}}
{{- if .Values.image.digest -}}
{{ .Values.image.repository }}@{{ .Values.image.digest }}
{{- else -}}
{{- .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end -}}


{{- define "jenkins.service" -}}
{{ .Values.server.service.name | default "jenkins-service" | quote }}
{{- end -}}


{{- define "jenkins.serviceAccountName" -}}
{{ .Values.rbac.serviceAccountName | default "jenkins-admin" | quote }}
{{- end -}}


{{- define "jenkins.clusterRole" -}}
{{ include "jenkins.serviceAccountName" . }}
{{- end -}}


{{- define "jenkins.clusterRoleBinding" -}}
{{ include "jenkins.serviceAccountName" . }}
{{- end -}}

{{- define "jenkins.claim" -}}
{{ .Values.server.persistentVolume.name | default "jenkins-claim" | quote }}
{{- end -}}



