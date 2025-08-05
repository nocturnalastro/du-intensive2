{{- define "parts_network_defs" }}
  {{- $networks := list }}
  {{- range $net := (.networks | default list) }}
      {{- $networks = append $networks $net.network }}
  {{- end }}
  {{- if gt ((.networks | default list) | len) 0 }}
      {{- printf "k8s.v1.cni.cncf.io/networks: %s" ($networks | toJson | quote) | nindent .indent }}
  {{- end }}
{{- end }}
{{- define "parts_network_resources" }}
  {{- $indent := .indent }}
  {{- range $net := .networks }}
      {{- if (index $net "resource") }}
        {{- print ($net.resource | quote) ": '1'" | nindent $.indent }}
      {{- end }}
  {{- end }}
{{- end }}
