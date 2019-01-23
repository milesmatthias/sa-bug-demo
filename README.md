# sa-bug-demo

Demo showing bug with re-creating service accounts in GCP

# Setup

`gcloud config set project <your-project-id>`

I use Ruby to quickly test GCS permissions for the SA, so make sure you have Ruby, and the GCS gem:

`gem install google-cloud-storage`


# Run

`./demo_sa_bug.sh`
