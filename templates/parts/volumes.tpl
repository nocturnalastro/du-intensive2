{{- define "parts_volume_defs" }}
  {{- range $volume := .volumes }}
    {{- printf "- name: %s" ($volume.name | default $volume.value) | nindent $.indent }}
    {{- if eq $volume.type "configMap" }}
      {{- printf "  configMap:" | nindent $.indent }}
      {{- printf "    name: %s" $volume.value | nindent $.indent }}
    {{- else if eq $volume.type "secret" }}
      {{- printf "  secret:" | nindent $.indent }}
      {{- printf "    secretName: %s" $volume.value | nindent $.indent }}
    {{- else if eq $volume.type "persistentVolumeClaim" }}
      {{- printf "  persistentVolumeClaim:" | nindent $.indent }}
      {{- printf "    claimName: %s" $volume.value | nindent $.indent }}
    {{- else if eq $volume.type "emptyDir" }}
      {{- printf "  emptyDir: %s" ($volume.emptyDirConfig | default dict | toJson) | nindent $.indent }}
    {{- else if eq $volume.type "hostpath" }}
      {{- printf "  hostPath:" | nindent $.indent }}
      {{- printf "    path: %s" $volume.path | nindent $.indent }}
      {{- printf "    type: ''" | nindent $.indent }}
    {{- end }}
  {{- end }}
{{- end }}
{{- define "parts_volume_mounts" }}
  {{- range $volume := .volumes | default list }}
    {{- printf "- name: %s " ($volume.name | default $volume.value) | nindent $.indent }}
    {{- printf "  mountPath: %s" $volume.path | nindent $.indent }}
  {{- end }}
{{- end }}
