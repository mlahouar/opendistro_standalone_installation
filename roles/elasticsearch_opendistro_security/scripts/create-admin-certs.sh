
DN=$1
CA_key=$2
CA_key_pass=$3
CA_crt=$4

rm -rf admin.csr admin.crt admin.key admin_tmp.key admin_req.cnf
umask 0277

cat << EOF > admin_req.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DN}
EOF

echo "---------- Create the certificate key for Admin"
openssl genrsa -out admin_tmp.key 2048 2>/dev/null
openssl pkcs8 -in admin_tmp.key -topk8 -out admin.key -nocrypt

echo "---------- Create the signing (csr) for Admin"
openssl req -new -sha256 -key admin.key -subj "/${DN}" -out admin.csr -config admin_req.cnf

echo "---------- Generate the certificate using the csr and key along with the CA Root key"
openssl x509 -req -in admin.csr -CA ${CA_crt} -CAkey ${CA_key} -CAcreateserial -out admin.crt -days 3650 -sha256 -extensions v3_req -extfile admin_req.cnf -passin pass:${CA_key_pass}

rm -rf admin.csr admin_tmp.key admin_req.cnf
