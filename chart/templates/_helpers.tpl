{{/*
Expand the name of the chart.
*/}}
{{- define "todolist.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "todolist.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "todolist.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "todolist.labels" -}}
helm.sh/chart: {{ include "todolist.chart" . }}
{{ include "todolist.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "todolist.selectorLabels" -}}
app.kubernetes.io/name: {{ include "todolist.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "todolist.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "todolist.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create service account labels
*/}}
{{- define "todolist.serviceAccount.labels" -}}
azure.workload.identity/use: "true"
{{- end }}

{{/*
Frontend service and deployment labels
*/}}
{{- define "todolist.frontend.labels" -}}
{{- include "todolist.labels" . }}
app.kubernetes.io/role: frontend
{{- end }}

{{/*
Backend service and deployment labels
*/}}
{{- define "todolist.backend.labels" -}}
{{- include "todolist.labels" . }}
app.kubernetes.io/role: backend
{{- end }}

{{/*
Frontend service and deployment selectorLabels
*/}}
{{- define "todolist.frontend.selectorLabels" -}}
{{- include "todolist.selectorLabels" . }}
app.kubernetes.io/role: frontend
{{- end }}

{{/*
Backend service and deployment selectorLabels
*/}}
{{- define "todolist.backend.selectorLabels" -}}
{{- include "todolist.selectorLabels" . }}
app.kubernetes.io/role: backend
{{- end }}

{{/*
Frontend service Container port name
*/}}
{{- define "todolist.frontendService.portName" -}}
{{- default "http" .Values.frontendService.portName }}
{{- end }}

{{/*
Backend service Container port name
*/}}
{{- define "todolist.backendService.portName" -}}
{{- default "http" .Values.backendService.portName }}
{{- end }}

{{/*
Frontend service name
*/}}
{{- define "todolist.frontendService.name" -}}
{{ default "todolist-web" .Values.frontendService.name }}
{{- end }}

{{/*
Backend service name
*/}}
{{- define "todolist.backendService.name" -}}
{{ default "todolist-api" .Values.backendService.name }}
{{- end }}

{{/*
Frontend deployment name
*/}}
{{- define "todolist.frontendDeployment.name" -}}
{{ default "todolist-web" .Values.frontendDeployment.name }}
{{- end }}

{{/*
Backend deployment name
*/}}
{{- define "todolist.backendDeployment.name" -}}
{{ default "todolist-api" .Values.backendDeployment.name }}
{{- end }}


{{/*
Service account annotations
*/}}
{{- define "todolist.serviceAccount.annotations" -}}
{{ if .Values.serviceAccount.annotations }}
{{- with .Values.serviceAccount.annotations }}
{{- toYaml . }}
{{ end }}
{{- end -}}
azure.workload.identity/client-id: {{ .Values.serviceAccount.appId }}
azure.workload.identity/tenant-id: {{ .Values.serviceAccount.tenantId }}
{{- end }}
