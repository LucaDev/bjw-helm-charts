{{/*
Env field used by the container.
*/}}
{{- define "bjw-s.common.lib.container.field.env" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $containerObject := $ctx.containerObject -}}

  {{- $envValues := include "bjw-s.common.lib.container.getOption" (dict "ctx" $ctx "option" "env") -}}
  {{/* This is a terrible hack because Helm otherwise doesn't understand how to decode the object */}}
  {{- $envValues = printf "env:\n%s" ($envValues | indent 2) | fromYaml -}}
  {{- $envValues = $envValues.env -}}

  {{- /* Default to empty list */ -}}
  {{- $envList := list -}}

  {{- /* See if an override is desired */ -}}
  {{- if not (empty $envValues) -}}
    {{- if kindIs "slice" $envValues -}}
      {{- /* Env is a list so we assume the order is already as desired */ -}}
      {{- range $name, $var := $envValues -}}
        {{- if kindIs "int" $name -}}
          {{- $name = required "environment variables as a list of maps require a name field" $var.name -}}
        {{- end -}}
      {{- end -}}
      {{- $envList = $envValues -}}
    {{- else -}}
      {{- /* Env is a map so we must check if ordering is desired */ -}}
      {{- $graph := dict -}}

      {{- range $name, $var := $envValues -}}
        {{- if kindIs "map" $var -}}
          {{- /* Value is a map so ordering can be specified */ -}}
          {{- if empty (dig "dependsOn" nil $var) -}}
            {{- $_ := set $graph $name ( list ) -}}
          {{- else if kindIs "string" $var.dependsOn -}}
            {{- $_ := set $graph $name ( list $var.dependsOn ) -}}
          {{- else if kindIs "slice" $var.dependsOn -}}
            {{- $_ := set $graph $name $var.dependsOn -}}
          {{- end -}}
        {{- else -}}
          {{- /* Value is not a map so no ordering can be specified */ -}}
          {{- $_ := set $graph $name ( list ) -}}
        {{- end -}}
      {{- end -}}

      {{- $args := dict "graph" $graph "out" list -}}
      {{- include "bjw-s.common.lib.kahn" $args -}}

      {{- range $name := $args.out -}}
        {{- $envItem := dict "name" $name -}}
        {{- $envValue := get $envValues $name -}}

        {{- if kindIs "map" $envValue -}}
          {{- $envItem := merge $envItem (omit $envValue "dependsOn") -}}
        {{- else -}}
          {{- $_ := set $envItem "value" $envValue -}}
        {{- end -}}

        {{- $envList = append $envList $envItem -}}
      {{- end -}}

      {{- $args = dict -}}
    {{- end -}}
  {{- end -}}

  {{- if not (empty $envList) -}}
    {{- $output := list -}}
    {{- range $envList -}}
      {{- if hasKey . "value" -}}
        {{- if kindIs "string" .value -}}
          {{- $output = append $output (dict "name" .name "value" (tpl .value $rootContext)) -}}
        {{- else if or (kindIs "float64" .value) (kindIs "bool" .value) -}}
          {{- $output = append $output (dict "name" .name "value" (.value | toString)) -}}
        {{- else -}}
          {{- $output = append $output (dict "name" .name "value" .value) -}}
        {{- end -}}
      {{- else if hasKey . "valueFrom" -}}
        {{- $parsedValue := (tpl (.valueFrom | toYaml) $rootContext) | fromYaml -}}
        {{- $output = append $output (dict "name" .name "valueFrom" $parsedValue) -}}
      {{- else -}}
        {{- $output = append $output (dict "name" .name "valueFrom" (omit . "name")) -}}
      {{- end -}}
    {{- end -}}
    {{- $output | toYaml -}}
  {{- end -}}
{{- end -}}
