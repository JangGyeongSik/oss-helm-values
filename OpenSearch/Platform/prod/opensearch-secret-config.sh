# Root CA Key 및 인증서 생성
openssl req -new -nodes -x509 -days 3650 -config opensearch-root-ca-openssl.cnf -keyout root-ca-key.pem -out root-ca.pem

# Master 노드 키 및 인증서 생성
openssl req -new -nodes -keyout esnode-master-key.pem -out esnode-master.csr -config opensearch-master-node-openssl.cnf
openssl x509 -req -days 3650 -in esnode-master.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out esnode-master.pem -extensions req_ext -extfile opensearch-master-node-openssl.cnf

# Data 노드 키 및 인증서 생성
openssl req -new -nodes -keyout esnode-data-key.pem -out esnode-data.csr -config opensearch-data-node-openssl.cnf
openssl x509 -req -days 3650 -in esnode-data.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out esnode-data.pem -extensions req_ext -extfile opensearch-data-node-openssl.cnf

# 관리자 키 및 인증서 생성 
openssl req -new -nodes -keyout admin-key.pem -out admin.csr -config opensearch-admin-openssl.cnf
openssl x509 -req -days 3650 -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -out admin.pem -extensions req_ext -extfile opensearch-admin-openssl.cnf

# kubernetes Secret create
kubectl create secret generic opensearch-master-tls \
  --from-file=esnode-master.pem=./esnode-master.pem \
  --from-file=esnode-master-key.pem=./esnode-master-key.pem \
  --from-file=root-ca.pem=./root-ca.pem \
  --from-file=admin.pem=./admin.pem \
  --from-file=admin-key.pem=./admin-key.pem

# Opensearch SecurityConfig Settings 
# https://opensearch.org/docs/latest/security/configuration/security-admin/
chmod +x plugins/opensearch-security/tools/securityadmin.sh
./plugins/opensearch-security/tools/securityadmin.sh
./securityadmin.sh -cd ../securityconfig -cn opensearch-mkt-prod-wish-cluster \
  -cacert ../../../config/tls/root-ca.pem \
  -cert ../../../config/tls/admin.pem \
  -key ../../../config/tls/admin-key.pem