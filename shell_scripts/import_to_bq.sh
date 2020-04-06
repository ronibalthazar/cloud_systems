#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: ./import_to_bq.sh  bucket-name"
    exit
fi
PROJECT=$DEVSHELL_PROJECT_ID
BUCKET=$1

bq rm -r -f -d default

bq mk -d default

ONE_FILE=$(gsutil ls gs://${BUCKET}/pig/covid_19_complete/part-m-00000)
bq mk --external_table_definition=./covid_19_complete.json@CSV=$ONE_FILE default.covid_19_complete

ONE_FILE=$(gsutil ls gs://${BUCKET}/pig/covid_19_country_per_day/part-r-00000)
bq mk --external_table_definition=./covid_19_country_per_day.json@CSV=$ONE_FILE default.covid_19_country_per_day
