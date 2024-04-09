{{- define "jenkins.name" -}}
{{ .Values.app.name | default "jenkins" }}
{{- end -}}


{{- define "jenkins.namespace" -}}
{{ .Values.namespace | default .Values.app.namespace | quote }}
{{- end -}}


{{- define "jenkins.commonAnnotations" -}}
deployed: {{ now | date "2024-02-01" }}
app.kubernetes.io/name: {{ include "jenkins.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- with .Values.server.annotations }}
{{- toYaml . }}
{{- end -}}
{{- end -}}


{{- define "jenkins.commonLabels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "jenkins.name" . | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{- define "jenkins.server.selectorLabels" -}}
{{- with .Values.server.labels }}
{{- toYaml . }}
{{- end }}
app: {{ include "jenkins.name" . | quote }}
{{- end -}}


{{- define "jenkins.getImage" -}}
{{- if .Values.image.digest -}}
{{ .Values.image.repository }}@{{ .Values.image.digest }}
{{- else -}}
{{- .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end -}}


{{- define "jenkins.ui-service" -}}
{{- if .Values.server.service.name -}}
{{ .Values.server.service.name }}
{{ else }}
{{- printf "%s-ui" (include "jenkins.name" . ) | quote }}
{{- end -}}
{{- end -}}


{{- define "jenkins.master-service" -}}
{{ $service := ternary (.Values.server.service.name) (include "jenkins.name" .) false }}
{{- printf "%s-master" $service | quote }}
{{- end -}}


{{- define "jenkins.serviceAccountName" -}}
{{ .Values.rbac.serviceAccountName | default "jenkins-admin" | quote }}
{{- end -}}


{{- define "jenkins.Role" -}}
{{ include "jenkins.serviceAccountName" . }}
{{- end -}}


{{- define "jenkins.RoleBinding" -}}
{{ include "jenkins.serviceAccountName" . }}
{{- end -}}


{{- define "jenkins.claim" -}}
{{ .Values.server.persistentVolume.name | default "jenkins-claim" | quote }}
{{- end -}}



