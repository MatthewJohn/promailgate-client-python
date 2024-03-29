#!/bin/bash

set -e
set -x

devpi_server=http://fare-docker-reg.dock.studios:3141
export PIP_CONFIG_FILE=./.pip.conf

. ./build-env/bin/activate

python --version
pip --version

pip install "devpi-client>=2.3.0"

pip download -r requirements.txt -d build-env/reqs

python setup.py bdist_wheel -d build-env/dest

old_http_proxy=$http_proxy
old_https_proxy=$https_proxy
unset http_proxy
unset https_proxy

if devpi use ${devpi_server}>/dev/null
then
   devpi use ${devpi_server}/root/dockstudios --set-cfg \
    && if [ "x${DEVPI_PASSWORD}" == "x" ]; then devpi login $DEVPI_USERNAME; else devpi login $DEVPI_USERNAME --password=${DEVPI_PASSWORD}; fi \
    && devpi upload --from-dir --formats='*' ./build-env/dest ./build-env/reqs
else
    echo "No started devpi container found at ${devpi_server}"
fi

export http_proxy=${old_http_proxy}
export https_proxy=${old_https_proxy}

deactivate

