#!/bin/bash
# This script clears the terminal, displays a greeting and gives information
# about currently connected users.  The two example variables are set and displayed.

# decpricated
# March 2014 guide to BOSH on Google Compute Engine https://github.com/cf-platform-eng/bosh-google-cpi/tree/google-cpi
# March 2015 guide to BOSH on Goggle Compute Engine https://github.com/cf-platform-eng/bosh-google-cpi/blob/google-cpi/bosh_google_cpi/INSTALL.md

# How to set up a BOSH jumpox
# https://github.com/cf-platform-eng/bosh-google-cpi/blob/google-cpi/bosh_google_cpi/INSTALL.md

#gcloud CLI commands to create and copy the bosh-install jumpbox 
gcloud compute images create bosh-jumpbox --source-uri http://storage.googleapis.com/bosh-stemcells/bosh-jumpbox.tar.gz
gcloud compute instances create bosh-jumpbox-vm --image bosh-jumpbox  --scopes=compute-rw,storage-full
gcloud compute copy-files ./nolaspring-8fbb744515fd.p12  bosh-jumpbox-vm:/bosh-workspace/.ssh/
gcloud compute copy-files ./google_compute_engine bosh-jumpbox-vm:/bosh-workspace/.ssh/


#ssh into the machine
gcloud compute ssh bosh-jumpox-vm
#install go
cd /bosh-workspace/
git clone https://go.googlesource.com/go
#pull latest version
git checkout go1.4.1
#keep it as installed
git checkout -b go1.4.1_installed
#build
cd go/src
./all.sh
#add the bin to the command line
export PATH=$PATH:/bosh-workspace/go/bin
#add gopath
export GOPATH=/bosh-workspace
# install bosh-init https://github.com/cloudfoundry/bosh-init/blob/master/docs/build.md
go get -d github.com/cloudfoundry/bosh-init
#move into folder
cd $GOPATH/src/github.com/cloudfoundry/bosh-init
#build
bin/build # The bosh-init binary will be located in out/
# add tools
bin/go get golang.org/x/tools/cmd/v
#use go to install the cli https://github.com/frodenas/bosh-google-cpi/
cd /bosh-workspace
#add a dir for the bosh-cpi
mkdir bosh-cpi
#GO GET CPI
 go get github.com/frodenas/bosh-google-cpi/main
 # reserve an address
 gcloud compute addresses create bosh-director
 #pull down a config file
 Have a templated file stored in git
 need to populate with json key. its important to add a \ to all of the newline characters and \ in front of all ""

# at this point our direcrtor exists

#install ruby deps
sudo apt-get install build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev

#set bosh target
bosh target [x]
#next install the bosh clis
$ gem install bosh_cli bosh_cli_plugin_micro --no-ri --no-rdoc

#drop the static IP for bosh-director, create one for CF
cf_ip=$(gcutil reserveaddress --region us-central1 cloudfoundry | grep RESERVED | awk '{ print $8 }')
#add some prot dforwarding rules for CF
gcutil addforwardingrule cloudfoundry --description="CloudFoundry" --region us-central1 --target_pool cloudfoundry --port_range 80 --ip ${cf_ip}
#open up some firewall holes
gcutil addfirewall cloudfoundry --description="CloudFoundry" --target_tags="cf" --allowed="tcp:80,tcp:443"
#upload our stemcell
bosh upload stemcell light-bosh-stemcell-2479-google-kvm-ubuntu-trusty.tgz
#upload our release
bosh upload release releases/cf-170.tgz
