{{- define "minecraft.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "minecraft.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "minecraft.labels" -}}
helm.sh/chart: {{ include "minecraft.name" . }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "minecraft.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: minecraft-server
{{- end }}

{{- define "minecraft.selectorLabels" -}}
app.kubernetes.io/name: {{ include "minecraft.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}