{{- /*
The container definition included in the Pod.
*/ -}}
{{- define "bjw-s.common.lib.container.spec" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $containerType := .containerType -}}
  {{- $containerObject := .containerObject -}}
  {{- $ctx := dict "rootContext" $rootContext "controllerObject" $controllerObject "containerType" $containerType "containerObject" $containerObject -}}

name: {{ include "bjw-s.common.lib.container.field.name" (dict "ctx" $ctx) | trim }}
image: {{ include "bjw-s.common.lib.container.field.image" (dict "ctx" $ctx) | trim }}
  {{- with $containerObject.image.pullPolicy }}
imagePullPolicy: {{ . | trim }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.field.command" (dict "ctx" $ctx) | trim) }}
command: {{ . | trim | nindent 2 }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.field.args" (dict "ctx" $ctx) | trim) }}
args: {{ . | trim | nindent 2 }}
  {{- end -}}
  {{- with $containerObject.workingDir }}
workingDir: {{ . | trim }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.getOption" (dict "ctx" $ctx "option" "securityContext")) }}
securityContext: {{ . | nindent 2 }}
  {{- end -}}
  {{- with $containerObject.lifecycle }}
lifecycle: {{ toYaml . | trim | nindent 2 }}
  {{- end -}}
  {{- with $containerObject.terminationMessagePath }}
terminationMessagePath: {{ . | trim }}
  {{- end -}}
  {{- with $containerObject.terminationMessagePolicy }}
terminationMessagePolicy: {{ . | trim }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.field.env" (dict "ctx" $ctx) | trim) }}
env: {{ . | trim | nindent 2 }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.field.envFrom" (dict "ctx" $ctx) | trim) }}
envFrom: {{ . | trim | nindent 2 }}
  {{- end -}}
  {{- with $containerObject.ports }}
ports: {{ toYaml . | trim | nindent 2 }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.field.probes" (dict "ctx" $ctx) | trim) }}
    {{- . | trim | nindent 0 -}}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.getOption" (dict "ctx" $ctx "option" "resources")) }}
resources: {{ . | nindent 2 }}
  {{- end -}}
  {{- with $containerObject.restartPolicy }}
restartPolicy: {{ . | trim }}
  {{- end -}}
  {{- with $containerObject.stdin }}
stdin: {{ . }}
  {{- end -}}
  {{- with $containerObject.tty }}
tty: {{ . }}
  {{- end -}}
  {{- with (include "bjw-s.common.lib.container.field.volumeMounts" (dict "ctx" $ctx) | trim) }}
volumeMounts: {{ . | trim | nindent 2 }}
  {{- end -}}
{{- end -}}
