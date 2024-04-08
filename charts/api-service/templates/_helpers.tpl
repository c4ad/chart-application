{{/*
Expand the name of the chart.
*/}}
{{- define "api-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "api-service.fullname" -}}
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
{{- define "api-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "api-service.labels" -}}
helm.sh/chart: {{ include "api-service.chart" . }}
{{ include "api-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: {{ .Values.app.name | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "api-service.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.app.name | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Values.app.name | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "api-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "api-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Environment variables template
*/}}
{{- define "api-service.env" -}}
{{- range $key, $value := .Values.environments }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $.Release.Name }}-configmap  {{- /* Corrected .Release.Name reference */}}
      key: {{ $key }}
{{- end }}
{{- range $key, $value := .Values.secrets }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-secret  {{- /* Corrected .Release.Name reference */}}
      key: {{ $key }}
{{- end }}
{{- range $key, $value := .Values.signedCookies }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-cloudfront  {{- /* Corrected .Release.Name reference */}}
      key: {{ $key }}
{{- end }}
{{- end }}

{{/*
Probes template
*/}}
{{- define "api-service.probes" -}}
startupProbe:
  {{- if .Values.deployment.startupProbe.execProbeCommand }}
  exec:
    command:
    {{- range $index, $value := .Values.deployment.startupProbe.execProbeCommand }}
      - {{ $value }}
    {{- end }}
  {{- else if .Values.deployment.startupProbe.tcpSocket }}
  tcpSocket:
    port: {{ .Values.deployment.startupProbe.tcpSocket }}
  {{- else }}
  httpGet:
    {{- if .Values.deployment.startupProbe.httpHeaders }}
    httpHeaders:
      - name: {{ .Values.deployment.startupProbe.httpHeaders.name | quote }}
        value: {{ .Values.deployment.startupProbe.httpHeaders.value | quote }}
    {{- end }}
    path: {{ .Values.deployment.startupProbe.path }}
    port: {{ .Values.deployment.startupProbe.port | default 8080 }}
  failureThreshold: {{ .Values.deployment.startupProbe.failureThreshold | default 10 }}
  periodSeconds: {{ .Values.deployment.startupProbe.periodSeconds | default 5 }}
  {{- end }}
livenessProbe:
  {{- include "api-service.customProbe" .Values.deployment.livenessProbe | nindent 2 }}
readinessProbe:
  {{- include "api-service.customProbe" .Values.deployment.readinessProbe | nindent 2 }}
{{- end }}

{{/*
Custom Probe template
*/}}
{{- define "api-service.customProbe" -}}
{{- if .execProbeCommand }}
exec:
  command:
  {{- range $index, $value := .execProbeCommand }}
    - {{ $value }}
  {{- end }}
{{- else if .tcpSocket }}
tcpSocket:
  port: {{ .tcpSocket }}
{{- else }}
httpGet:
  path: {{ .path }}
  port: {{ .port | default 8080 }}
{{- end }}
initialDelaySeconds: {{ .initialDelaySeconds | default 5 }}
periodSeconds: {{ .periodSeconds | default 1 }}
timeoutSeconds: {{ .timeoutSeconds | default 1 }}
successThreshold: {{ .successThreshold | default 1 }}
failureThreshold: {{ .failureThreshold | default 1 }}
{{- end }}
