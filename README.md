atmos2s3
========

#### modify the env.sh to fill the Credentials for ATMOS and S3:
``` 
export BLOB_ATMOS_UID= <atmos uid> 
export BLOB_ATMOS_SECRET= <token for atmos > 
export BLOB_ATMOS_TAG= <all blobs with this tag will be copied> 
export BLOB_AWS_ACCESS_KEY_ID= <aws access id> 
export BLOB_AWS_SECRET_ACCESS_KEY= <aws secret key>
export BLOB_S3_BUCKET= <S3 bucket you want to hold the key>
```

#### source ./env.sh

#### bundle install

#### ruby ./copy2s3.rb
