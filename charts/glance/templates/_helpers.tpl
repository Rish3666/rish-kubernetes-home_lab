{{- /* ── glance/templates/_helpers.tpl ───────────────────────────────────────

WHY THIS FILE EXISTS:
  _helpers.tpl defines reusable named templates (Helm "partials") that are
  shared across multiple template files. Instead of duplicating the same name
  generation or label logic in deployment.yaml, service.yaml, and ingress.yaml,
  we define them once here and call them with {{ include "glance.X" . }}.

  Helm processes _helpers.tpl before any other template file (alphabetical
  ordering: underscore comes first). These are "defines" not "templates" —
  they don't produce output on their own. They just register named blocks.

WHY EACH HELPER EXISTS:

  glance.name:
    The base name of the app. If nameOverride is set, use that; otherwise
    use .Chart.Name ("glance"). Truncated to 63 chars (DNS label limit)
    with trailing dashes removed.

  glance.fullname:
    The fully-qualified name including the release name. For example, if
    you run "helm install my-glance ." the fullname would be "my-glance-glance"
    (release name + chart name). This distinguishes resources when you deploy
    multiple releases of the same chart in one namespace. Truncated to 63
    chars because Kubernetes resource names must be valid DNS subdomains.

  glance.labels:
    Standard recommended Kubernetes labels. These enable:
      - Selectors: "app.kubernetes.io/name=glance" matches pods to services
      - Management: "helm.sh/chart=glance-0.1.0" shows what chart owns what
      - Version tracking: "app.kubernetes.io/version=0.8.5" shows the app
        version running
      - Audit: "app.kubernetes.io/managed-by=Helm" shows who manages this

  glance.selectorLabels:
    The subset of labels used by Service selectors and Deployment matchLabels.
    These MUST be unique per release so that Services only route to pods from
    their own release. If two releases have the same selector, traffic leaks.
*/ -}}

{{- define "glance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "glance.fullname" -}}
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

{{- define "glance.labels" -}}
helm.sh/chart: {{ include "glance.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "glance.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "glance.selectorLabels" -}}
app.kubernetes.io/name: {{ include "glance.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
