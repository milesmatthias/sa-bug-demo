#! /usr/bin/env bash

PROJECT=$(gcloud config get-value project)
BUCKET=role-bug-demo
SA_NAME=role-bug-demo-sa-5
SA_KEY_FILE=sa-key.json

# delete an existing service account (if exists)
# create the service account with same name
# grant it roles/storage.admin role
# get key for service account
function setupSA() {
  # get SA email
	SA_EMAIL=$(gcloud iam service-accounts list \
		--filter="displayName:$SA_NAME" \
		--format='value(email)')

	if [ -n "$SA_EMAIL" ]; then
		gcloud -q iam service-accounts delete $SA_EMAIL
		echo "Waiting 60 seconds for the service account to be deleted..."
		sleep 60
	else
		echo "Service account already deleted."
	fi

  # make a service account
  gcloud iam service-accounts create $SA_NAME \
    --display-name $SA_NAME

  # get SA email
  SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SA_NAME" \
    --format='value(email)')

  # give that service account roles/storage.admin
  gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin --member serviceAccount:$SA_EMAIL \
		--no-user-output-enabled
	echo "Added roles/storage.admin to $SA_EMAIL"

  # get service account key
  gcloud iam service-accounts keys create $SA_KEY_FILE \
    --iam-account $SA_EMAIL

	echo "Waiting 60 seconds after service account setup to test access"
	sleep 60
}

# make a bucket
gsutil mb -c regional -l us-central1 gs://$BUCKET

# upload a file
gsutil cp bar.txt gs://$BUCKET

# delete (if necessary), create, assign role, and get key for SA
setupSA

# should be able to get the item in GCS
ruby gcs_test.rb $PROJECT $SA_KEY_FILE

# re-create the service account with the same name
setupSA

# BUG: can't get the item in GCS
# EXPECT: to be able to get the item in GCS,
# since roles/storage.admin gives storage.*
ruby gcs_test.rb $PROJECT $SA_KEY_FILE
