{{- define "parts_extra_containers" }}
  {{/*
    Create extra container definitions.
    - .N_extra_containers: (int) Number of extra containers to create.
    - .Image_ubi: (string) The image to use for the containers.
    - .prefix: (string) A prefix for the container name.
    - .Replica: (string|int) The replica number/name.
    - .indent: (int) The base indentation level.

    Resource lists can be shorter than .N_extra_containers.
    If a list is shorter, the value from index 0 is used as the default.
    If a list is empty, a hardcoded default is used.
  */}}

  {{/* --- Prepare source lists, defaulting to empty lists if not provided --- */}}
  {{- $extra_volumes_list := .extra_volumes | default list -}}
  {{- $extra_cpu_limits_list := .extra_cpu_limits | default list -}}
  {{- $extra_mem_limits_list := .extra_mem_limits | default list -}}
  {{- $extra_cpu_requests_list := .extra_cpu_requests | default list -}}
  {{- $extra_mem_requests_list := .extra_mem_requests | default list -}}

  {{/* --- Safely determine the default value for each setting --- */}}
  {{- $default_vols := dict -}}
  {{- if gt (len $extra_volumes_list) 0 -}}
    {{- $default_vols = index $extra_volumes_list 0 -}}
  {{- end -}}

  {{- $default_cpu_limit := "50m" -}}
  {{- if gt (len $extra_cpu_limits_list) 0 -}}
    {{- $default_cpu_limit = index $extra_cpu_limits_list 0 -}}
  {{- end -}}

  {{- $default_mem_limit := "150Mi" -}}
  {{- if gt (len $extra_mem_limits_list) 0 -}}
    {{- $default_mem_limit = index $extra_mem_limits_list 0 -}}
  {{- end -}}

  {{- $default_cpu_request := $default_cpu_limit -}}
  {{- if gt (len $extra_cpu_requests_list) 0 -}}
    {{- $default_cpu_request = index $extra_cpu_requests_list 0 -}}
  {{- end -}}

  {{- $default_mem_request := $default_mem_limit -}}
  {{- if gt (len $extra_mem_requests_list) 0 -}}
    {{- $default_mem_request = index $extra_mem_requests_list 0 -}}
  {{- end -}}

  {{/* --- Loop and generate containers --- */}}
  {{- range $i := until (.N_extra_containers | default 0) -}}
    {{/* Get the specific value for this container, or fall back to the default */}}
    {{- $vols := $default_vols -}}
    {{- if gt (len $extra_volumes_list) $i -}}
      {{- $vols = index $extra_volumes_list $i -}}
    {{- end -}}

    {{- $cpu_limit := $default_cpu_limit -}}
    {{- if gt (len $extra_cpu_limits_list) $i -}}
      {{- $cpu_limit = index $extra_cpu_limits_list $i -}}
    {{- end -}}

    {{- $mem_limit := $default_mem_limit -}}
    {{- if gt (len $extra_mem_limits_list) $i -}}
      {{- $mem_limit = index $extra_mem_limits_list $i -}}
    {{- end -}}

    {{- $cpu_req := $default_cpu_request -}}
    {{- if gt (len $extra_cpu_requests_list) $i -}}
      {{- $cpu_req = index $extra_cpu_requests_list $i -}}
    {{- end -}}

    {{- $mem_req := $default_mem_request -}}
    {{- if gt (len $extra_mem_requests_list) $i -}}
      {{- $mem_req = index $extra_mem_requests_list $i -}}
    {{- end -}}

    {{- print "- image: " $.Image_ubi | nindent $.indent }}
    {{- print "  imagePullPolicy: IfNotPresent" | nindent $.indent }}
    {{- printf "  name: extra-%s-container-%d" $.Replica $i | nindent $.indent }}
    {{- print "  command: ['sleep', 'inf']" | nindent $.indent }}
    {{- if gt (len $vols) 0 }}
      {{- print "  volumeMounts:" | nindent $.indent }}
      {{- template "parts_volume_mounts" (dict "volumes" $vols "indent" (add $.indent 2)) }}
    {{- end }}
    {{- print "  resources:" | nindent $.indent }}
    {{- print "    requests:" | nindent $.indent }}
    {{- printf "      cpu: %q" $cpu_req | nindent $.indent }}
    {{- printf "      memory: %q" $mem_req | nindent $.indent }}
    {{- print "    limits:" | nindent $.indent }}
    {{- printf "      cpu: %q" $cpu_limit | nindent $.indent }}
    {{- printf "      memory: %q" $mem_limit | nindent $.indent }}
  {{- end -}}
{{- end -}}