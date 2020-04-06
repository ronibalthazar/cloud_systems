#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./upload_results_to_bucket.sh source-hdfs-directory destination-bucket-name"
    exit
fi

FROM=$1
BUCKET=$2
TO=gs://$BUCKET

# Create Bucket
gsutil mb gs://$BUCKET/

# Empty bucket if it exists
gsutil rm -r -f gs://$BUCKET/*

# Copy data from HDFS to the bucket
mkdir -p /tmp/pig
hadoop fs -get $FROM/* /tmp/pig/
gsutil -m cp -r /tmp/pig/* gs://$BUCKET/pig/
rm -rf /tmp/pig
