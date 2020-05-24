#!/usr/bin/env bash

. ./custom_ports_02_commons.sh

# sudo bash -c 'mkdir -p /usr/local/etc/poudriere.d/options/sysutils_beats7/'
# sudo bash -c 'cat > /usr/local/etc/poudriere.d/options/sysutils_beats7/options <<EOF
# # Options for beats7
# _OPTIONS_READ=beats7
# _FILE_COMPLETE_OPTIONS_LIST=AUDITBEAT FILEBEAT HEARTBEAT METRICBEAT PACKETBEAT
# OPTIONS_FILE_SET+=AUDITBEAT
# OPTIONS_FILE_SET+=FILEBEAT
# OPTIONS_FILE_SET+=HEARTBEAT
# OPTIONS_FILE_SET+=METRICBEAT
# OPTIONS_FILE_SET+=PACKETBEAT
# EOF'

sudo bash -c "echo 'BATCH=yes' > /usr/local/etc/poudriere.d/${CUSTOM_PORT_RELEASE_TARGET_MINIFIED}-make.conf"
sudo bash -c "echo 'ALLOW_UNSUPPORTED_SYSTEM=yes' >> /usr/local/etc/poudriere.d/${CUSTOM_PORT_RELEASE_TARGET_MINIFIED}-make.conf"
sudo poudriere jail -c -j ${CUSTOM_PORT_RELEASE_TARGET_MINIFIED} -v ${CUSTOM_PORT_RELEASE_TARGET} -a ${CUSTOM_PORT_ARCH_TARGET}
for CUSTOM_PORT_PATH in ${CUSTOM_PORTS_PATH} ; do
    CUSTOM_PACKAGE_NAME=$(cd /usr/local/poudriere/ports/default/${CUSTOM_PORT_PATH} ; make package-name)
    if [ -f ${CUSTOM_PORT_WORKING_DIR}/.options ]; then 
        sudo bash -c "mkdir -p /usr/local/etc/poudriere.d/options/\$(echo ${CUSTOM_PORT_PATH}|sed -e 's/\//_' )/"
        sudo bash -c "cp ${CUSTOM_PORT_WORKING_DIR}/.options /usr/local/etc/poudriere.d/options/\$(echo ${CUSTOM_PORT_PATH}|sed -e 's/\//_' )/options"
    fi
    #sudo poudriere testport -j ${CUSTOM_PORT_RELEASE_TARGET_MINIFIED} -p default ${CUSTOM_PORT_PATH}
    #sudo poudriere bulk -j ${CUSTOM_PORT_RELEASE_TARGET_MINIFIED} -p default ${CUSTOM_PORT_PATH}
    sudo mkdir -p ${CUSTOM_PORT_TMP_DIR}/artefacts/${CUSTOM_PORT_RELEASE_TARGET}
    sudo bash -c "cd /usr/local/poudriere/ports/default/ ; shar \$(find ${CUSTOM_PORT_PATH}/ |grep -v -e README.md -e .options) > /usr/local/poudriere/data/packages/${CUSTOM_PORT_RELEASE_TARGET_MINIFIED}-default/All/$(echo ${CUSTOM_PORT_PATH}|sed -e 's/\//_' ).shar "
    sudo rsync -av /usr/local/poudriere/data/packages/${CUSTOM_PORT_RELEASE_TARGET_MINIFIED}-default/All/ ${CUSTOM_PORT_TMP_DIR}/artefacts/${CUSTOM_PORT_RELEASE_TARGET}/
    echo Artefact location: ${CUSTOM_PORT_TMP_DIR}/artefacts/${CUSTOM_PORT_RELEASE_TARGET}/ 
    ls -1 ${CUSTOM_PORT_TMP_DIR}/artefacts/${CUSTOM_PORT_RELEASE_TARGET}/*
done