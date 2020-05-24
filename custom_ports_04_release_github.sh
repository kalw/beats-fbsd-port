#!/usr/bin/env bash

. ./custom_ports_02_commons.sh

if [[ "$CIRRUS_RELEASE" == "" ]]; then
echo "Not a release. No need to deploy!"
exit 0
fi

if [[ "$GITHUB_TOKEN" == "" ]]; then
echo "Please provide GitHub access token via GITHUB_TOKEN environment variable!"
exit 1
fi

# Release notes
sudo pkg install npm-node12
#bash -xc 'sudo npm install semantic-release $(grep -o -e "@semantic-release/[^\"]*" .releaserc ) -g -D git-release-notes'
#sudo npm install -g npx github-release-notes git-release-notes
cd ${CUSTOM_PORT_WORKING_DIR}
#sudo npx semantic-release@16

# create release note
# create release

{
  "tag_name": "${CIRRUS_RELEASE}",
  "target_commitish": "master",
  "name": "${CIRRUS_RELEASE}",
  "body": "Description of the release",
  "draft": false,
  "prerelease": false
}

# Upload Files 
for CUSTOM_PORT_PATH in ${CUSTOM_PORTS_PATH} ; do
    CUSTOM_PACKAGE_NAME="$(cd /usr/local/poudriere/ports/default/${CUSTOM_PORT_PATH} ; make package-name).txz"
    CUSTOM_PORT_SHAR_NAME="$(echo ${CUSTOM_PORT_PATH}|sed -e 's/\//_' ).shar"
    file_content_type="application/octet-stream"
    files_to_upload=$(cd ${CIRRUS_WORKING_DIR}/artefacts/ && find . -type f |grep -e ${CUSTOM_PACKAGE_NAME} -e ${CUSTOM_PORT_SHAR_NAME} )

    for fpath in $files_to_upload
    do
    echo "Uploading $fpath..."
    name=$(echo "$fpath" | sed -e 's/\//_/g')
    url_to_upload="https://uploads.github.com/repos/$CIRRUS_REPO_FULL_NAME/releases/$CIRRUS_RELEASE/assets?name=$name"
    curl -X POST \
    --data-binary @$fpath \
    --header "Authorization: token $GITHUB_TOKEN" \
    --header "Content-Type: $file_content_type" \
    $url_to_upload
    done
done