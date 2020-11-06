#!/bin/bash
dbName=$1
key=$2

brew install sqlcipher

if [ -z "$key" ] ; then 
	echo "Please provide a database and key"
	exit 1
fi

# load key from file
key=$(cat $key);
dbName_plain="${dbName}_plain.db"
dbName_enc="${dbName}.db"


# remove existing plain database 
rm -f "$dbName_plain"

echo "Decrypting $dbName using key $key"

sqlcipher $dbName_enc <<-EOF
.timeout 2000
PRAGMA cipher_default_kdf_iter = 1;
PRAGMA key = '$key';
PRAGMA kdf_iter = 1;
PRAGMA cipher_memory_security = OFF;
select count(*) from sqlite_master;
ATTACH DATABASE '${dbName_plain}' AS plaintext KEY '';
SELECT sqlcipher_export('plaintext');
DETACH DATABASE plaintext;
EOF

echo "Done."
