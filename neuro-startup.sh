#!/bin/bash

apt-get update
apt-get install -y docker.io
mkdir -p /home/aculich/work
chown aculich:aculich /home/aculich/work
docker pull aculich/wip-neuro
docker rm -f wip-neuro
docker run --name wip-neuro -p 80:8888 -v /home/aculich/work:/home/jovyan/work -e GRANT_SUDO=yes  -d aculich/wip-neuro start-notebook.sh --NotebookApp.password='sha1:06dbcd27b65a:c4605b48a6a554d19ad61d99d427d809772a1baf'
sudo docker exec -it wip-neuro git clone https://github.com/choldgraf/UCSF-Data_Driven_Neuro /home/jovyan/work/UCSF-Data_Driven_Neuro
docker exec -it wip-neuro /home/jovyan/fetch_data.py
