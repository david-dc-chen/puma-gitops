# gateway

This chart deploys the API Gateway.

## Install gateway

The API Gateway requires a license for its installation either provided at helm install or retrieved from vault.

`helm dep build gateway`

`helm install gateway --name "<release name>" -f override.yaml --set-file "gateway.license.value=<license file>" --set gateway.license.accept="true"`


To delete gateway installation: (Use the release name that you previously specified to install the gateway along with the --name parameter)

`helm del --purge <release name>`


## Configuration

The following table lists the configurable parameters of the Nexus chart and their default values.

| Parameter                        | Description                               | Default                                                      |
| -----------------------------    | -----------------------------------       | -----------------------------------------------------------  |
| `replicaCount`                   | Number of Gateway service replicas        | `1`                                                          |
| `deploymentStrategy`             | Deployment Strategy                       | `rollingUpdate`                                              |
| `nexus.imageName`                | Nexus Docker Private Repository Gateway   | `docker.k8s.apimsvc.ca.com/repository/docker-hosted/gateway` |
| `nexus.tag`                      | Version of Gateway                        | `latest`                                                     |
| `nexus.imagePullPolicy`          | Nexus image pull policy                   | `Always`                                                     |
| `imageCredentials.name`          | Image Secret credentials to fetch image from private repo | `docker.k8s.apimsvc.ca.com`  |
| `imageCredentials.registry`          | Image Secret repo name to fetch image from private repo | `docker.k8s.apimsvc.ca.com`  |
| `imageCredentials.username`          | Image Secret username credential | `nil`  |
| `imageCredentials.password`          | Image Secret password credential | `nil`  |
| `heapSize`          | Gateway application heap size | 3g  |
| `license.value`          | Gateway license file | `nil`  |
| `license.accept`          | Accept Gateway license EULA | `false`  |
| `javaArgs`          | Additional gateway application java args | `nil`  |
| `service.ports`    | List of http external port mappings               | http: 80 -> 8080, https: 443->8443 |
| `hazelcast.enable`    | Provision Hazelcast               | true |
| `influxdb.host`    | influxdb host               | 'influx-influxdb.<namespace>' |
| `vault.generateSslKey`    | Use a default ssl key from vault at boot up   |false |
| `vault.gatewayLicense`    | Use license from vault at boot up   |false |
| `vault.address`    | Vault server address   |https://apim-vault:8200 |
| `vault.skipVerify`    | Skip verification of vault server ssl certificate   | true |
| `vault.serviceAccount`    | k8s service account name that will be created at helm install |gateway-vault |
| `vault.role`    | The vault role that k8s service account has been assigned to   |gateway |
| `vault.initContainerImage`    | The image for init container that retrieves secrets from vault.   |docker.k8s.apimgcp.com/repository/docker-hosted/openssl_consul |
| `vault.initContainerTag`    | The tag for init container.   |"init1" |
| `vault.mountPath`    | Where the shared directory should be mounted on both containers   | /opt/vault |



### Logs & Audit Configuration

The API Gateway containers are configured to output logs and audits as JSON events, and to never write audits to the in-memory Derby database:

- System properties in the default template for the `gateway.javaArgs` value configure the log and audit behaviour:
  - Auditing to the database is disabled: `-Dcom.l7tech.server.audit.message.saveToInternal=false -Dcom.l7tech.server.audit.admin.saveToInternal=false -Dcom.l7tech.server.audit.system.saveToInternal=false`
  - JSON formatting is enabled: `-Dcom.l7tech.server.audit.log.format=json`
  - Default log output configuration is overridden by specifying an alternative configuration properties file: `-Djava.util.logging.config.file=/opt/SecureSpan/Gateway/node/default/etc/conf/log-override.properties`
- The alternative log configuration properties file `log-override.properties` is mounted on the container, via the `gateway-config` ConfigMap.
- System property to include well known Certificate Authorities Trust Anchors 
    - API Gateway does not implicitly trust certificates without importing it but If you want to avoid import step then configure Gateway to accept any certificate signed by well known CA's (Certificate Authorities)
      configure following property to true -
      Set '-Dcom.l7tech.server.pkix.useDefaultTrustAnchors=true' for well known Certificate Authorities be included as Trust Anchors (true/false)
- Allow wildcards when verifying hostnames (true/false)
    - Set '-Dcom.l7tech.security.ssl.hostAllowWildcard=true' to allow wildcards when verifying hostnames (true/false)
    
### Secrets from Vault
Vault can be used to hold secrets that gateway use at boot up, e.g. default ssl key, license, and bundles. An init container can be used to retrieve secrets from vault and pass as files to gateway to bootstrap.