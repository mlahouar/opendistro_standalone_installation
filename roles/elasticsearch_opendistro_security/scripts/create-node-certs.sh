#!/bin/bash

CN=$1
CA_key=$2
CA_key_pass=$3
CA_crt=$4
FN=$CN

rm -rf ${CN}.csr ${CN}.crt ${CN}.key ${CN}_tmp.key ${CN}_req.cnf
umask 0277

cat << EOF > ${CN}_req.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${CN}
EOF

echo "---------- Create the certificate key for $i"
openssl genrsa -out ${CN}_tmp.key 2048 2>/dev/null
openssl pkcs8 -in ${CN}_tmp.key -topk8 -out ${CN}.key -nocrypt

echo "---------- Create the signing (csr) for $i"
openssl req -new -sha256 -key ${CN}.key -subj "/CN=${CN}" -out ${CN}.csr -config ${CN}_req.cnf

echo "---------- Generate the certificate using the csr and key along with the CA Root key"
openssl x509 -req -in ${CN}.csr -CA ${CA_crt} -CAkey ${CA_key} -CAcreateserial -out ${CN}.crt -days 3650 -sha256 -extensions v3_req -extfile ${CN}_req.cnf -passin pass:${CA_key_pass}

rm -rf ${CN}.csr ${CN}_tmp.key ${CN}_req.cnf
