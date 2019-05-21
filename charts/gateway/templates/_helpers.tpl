{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateway.fullname" -}}
{{- if .Values.gateway.fullnameOverride -}}
{{- .Values.gateway.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.gateway.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create java args to apply.
*/}}
{{- define "gateway.java.args.hazelcast" -}}
{{- printf "%s" "-Dcom.l7tech.server.extension.sharedCounterProvider=externalhazelcast -Dcom.l7tech.server.extension.sharedKeyValueStoreProvider=externalhazelcast -Dcom.l7tech.server.extension.sharedClusterInfoProvider=externalhazelcast" -}}
{{- end -}}

{{- define "gateway.java.args.vault" -}}
{{- printf "%s%s%s" "-Dcom.l7tech.common.security.jceProviderEngineName=generic -Dcom.l7tech.keystore.type=PKCS12 -Dcom.l7tech.keystore.path=" .Values.vault.mountPath "/ssl.p12 -Dcom.l7tech.keystore.savePath=EMPTY -Dcom.l7tech.keystore.password=password -Dcom.l7tech.common.security.jceProviderEngine=com.l7tech.security.prov.generic.GenericJceProviderEngine" -}}
{{- end -}}

{{- define "gateway.java.args" -}}
{{- $default := default .Values.gateway.javaArgs  "-Dcom.l7tech.bootstrap.autoTrustSslKey=trustAnchor,TrustedFor.SSL,TrustedFor.SAML_ISSUER -Dcom.l7tech.server.audit.message.saveToInternal=false -Dcom.l7tech.server.audit.admin.saveToInternal=false -Dcom.l7tech.server.audit.system.saveToInternal=false -Dcom.l7tech.server.audit.log.format=json -Djava.util.logging.config.file=/opt/SecureSpan/Gateway/node/default/etc/conf/log-override.properties -Dcom.l7tech.server.pkix.useDefaultTrustAnchors=true -Dcom.l7tech.security.ssl.hostAllowWildcard=true" -}}
{{- if and .Values.hazelcast.enabled .Values.vault.generateSslKey -}}
{{- printf "%s %s %s" $default (include "gateway.java.args.hazelcast" .) (include "gateway.java.args.vault" .) -}}
{{- else if .Values.hazelcast.enabled -}}
{{- printf "%s %s" $default (include "gateway.java.args.hazelcast" .) -}}
{{- else if .Values.vault.generateSslKey -}}
{{- printf "%s %s" $default (include "gateway.java.args.vault" .) -}}
{{- else -}}
{{- printf "%s" $default -}}
{{- end -}}
{{- end -}}

