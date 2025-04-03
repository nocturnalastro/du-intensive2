{{- define "volumes_func" -}}
    {{- $volumes := index . 0  }}
    {{- $indent := index . 1  }}
    {{- $result := list }}
    {{- range $volume := $volumes }}
        {{- $item := dict "name" ($volume.name | default $volume.value) }}
        {{- if eq $volume.type "configMap" }}
        {{- $_ := set $item "configMap" (dict "name" $volume.value) }}
        {{- else if eq $volume.type "secret" }}
        {{- $_ := set $item "secret" (dict "secretName" $volume.value) }}
        {{- else if eq $volume.type "persistentVolumeClaim" }}
        {{- $_ := set $item "persistentVolumeClaim" (dict "claimName" $volume.value) }}
        {{- else if eq $volume.type "emptyDir" }}
        {{- $_ := set $item "emptyDir" ($volume.emptyDirConfig | default dict) }}
        {{- else if eq $volume.type "hostpath" }}
        {{- $_ := set $item "hostPath" (dict "path" $volume.path "type" "") }}
        {{- end }}
        {{- $result = append $result $item }}
    {{- end }}
{{- $result | toPrettyJson | indent $indent }}
{{- end }}