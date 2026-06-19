#!/usr/bin/env bash

echo_and_exec() {
    echo "> $@"
    "$@"
}

#set -e # halt on error

#rm -rf bin/ && echo "Deleted bin/"
DEV_KEY="${HOME}/.Garmin/ConnectIQ/developer_key.der"
SDK="$(cat "${HOME}/.Garmin/ConnectIQ/current-sdk.cfg")"
# edit the following line to point to your developer key



echo "Application name=${APP_NAME}, version=${APP_VERSION}"

PROJECT_FOLDER=${PWD}
#PROJECT_NAME=$(basename "${PROJECT_FOLDER}")
#PROJECT_NAME="SlavicGearIndex"


#APP_TEST_ID="c4755d9c-e9e1-4924-b458-04e708ce9999"
#APP_PROD_ID="c4755d9c-e9e1-4924-b458-04e708ce0000"

# Branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)

#APP_ID="c4755d9c-e9e1-4924-b458-04e708ce8888" # DEVELOP
#APP_ID="c4755d9c-e9e1-4924-b458-04e708ce9999" # TEST
#APP_ID="c4755d9c-e9e1-4924-b458-04e708ce0001" # PRODUCTION


if [[ ${BRANCH} == "main" ]]; then
    # Main count of commits without merges
    APP_FILE=resources/strings/app.xml
    APP_NAME=$(xmllint --xpath "//strings/string[@id='AppName']/text()" ${APP_FILE})
    APP_VERSION=$(xmllint --xpath "//strings/string[@id='version']/text()" ${APP_FILE})
else
    git status manifest.xml | grep manifest.xml
    if [ $? -eq 0 ]; then
        echo_and_exec git diff manifest.xml >&2
        echo -e "\nManifest file must by edited only in branch main!" >&2
        echo "Manualy execute: git restore manifest.xml" >&2
        echo "exit 1" >&2
        exit 1;
    fi
    APP_FILE=resourcesTest/strings/app.xml
#    [[ ${BRANCH} == "test" ]] && 
    APP_NAME=$(xmllint --xpath "//strings/string[@id='AppName']/text()" ${APP_FILE})
    APP_VERSION=$(xmllint --xpath "//strings/string[@id='version']/text()" ${APP_FILE})
    APP_VERSION=${APP_VERSION}.${BRANCH}
fi;


GITCOUNT=$(git rev-list --count HEAD)
GITCOUNT=$(git log "${APP_VERSION}.0"..HEAD | wc -l)

echo "Branch ${BRANCH} ${SYSTEM} v. ${APP_VERSION}"

#echo "  Write Application@id=${APP_ID} on ${BRANCH} on version ${APP_VERSION}"
#echo -e "setns iq=http://www.garmin.com/xml/connectiq\ncd //iq:manifest/iq:application/@id\nset ${APP_ID}\nsave\nbye" | xmllint --shell manifest.xml | grep -v ">" 

#echo "Set AppName=${APP_NAME} ${APP_VERSION}.${GITCOUNT}"
#echo -e "cd /strings/string[@id=\"AppName\"]\nset ${APP_NAME} ${APP_VERSION}.${GITCOUNT}\nsave" | xmllint --shell ${APP_FILE} | grep -v ">"
echo "Set version=${APP_VERSION}.${GITCOUNT}"
echo -e "cd /strings/string[@id=\"version\"]\nset ${APP_VERSION}.${GITCOUNT}\nsave" | xmllint --shell ${APP_FILE} | grep -v ">"



#xmllint --xpath "/strings/string[@id='AppName']/text()" ${APP_FILE}
#xmllint --xpath "/strings/string[@id='version']/text()" ${APP_FILE}


echo -e "\n****************************************\nBUILD ${APP_NAME} ${APP_VERSION}.${GITCOUNT}\n----------------------------------------"

if [[ ${BRANCH}=="main" || ${BRANCH}=="test" ]]; then
    find bin/ -type f -name "${APP_NAME}-*.iq" -exec rm {} \;
    echo -e "\nGenerate ${APP_NAME}-${GITCOUNT}..."
    echo_and_exec java -Xms1g -"Dfile.encoding=UTF-8" -"Dapple.awt.UIElement=true"    \
        -jar "${SDK}"bin/monkeybrains.jar \
        --output "bin/${APP_NAME}-${APP_VERSION}.${GITCOUNT}.iq"    \
        --jungles "monkey.jungle" \
        --private-key ${DEV_KEY}    \
        --package-app --release --warn
    echo -e "Generated bin/${APP_NAME}-${APP_VERSION}.${GITCOUNT}.iq"
fi;

declare -a devices=("edge840" "edge1050")

if [[ -n "${1}" ]]; then
    devices=("${1}")
fi;

JUNGLEPATHS="${PWD}/monkey.jungle"
## loop through above array (quotes are important if your elements may contain spaces)
[[ -d debug ]] || mkdir debug

for device in "${devices[@]}"; do
    echo "Device: ${device}"
    find bin/ -type f -name "${APP_NAME}-${device^}-*" -print -exec rm {} \;
    [[ -e "${PWD}/barrels.jungle" ]] && JUNGLEPATHS="${JUNGLEPATHS};${PWD}/barrels.jungle"
    echo_and_exec "${SDK}"bin/monkeyc \
        --private-key "${DEV_KEY}" --jungles "${JUNGLEPATHS}" \
        --device ${device} --output "bin/${APP_NAME}-${device^}-${APP_VERSION}.${GITCOUNT}.prg" \
        --warn --typecheck 1 --release
    # --debug-log-output logs/monkeyc.zip --debug-log-level 3 
    # echo_and_exec "${SDK}"/bin/monkeydo "${OUTPUT_FILE}" ${DEVICE}
    find bin/ -type f -name "${APP_NAME}-${device^}-*.json" -exec rm {} \;
    echo -e "\nGenerated bin/${APP_NAME}-${device^}-${APP_VERSION}.${GITCOUNT}.prg\n"
    cp -v bin/${APP_NAME}-${device^}-${APP_VERSION}.${GITCOUNT}.prg.debug.xml debug/
done

echo -e "########################################\n"

xmllint --xpath "//strings/string[@id='AppName']/text()" ${APP_FILE}
xmllint --xpath "//strings/string[@id='version']/text()" ${APP_FILE}

#git checkout -b "${APP_VERSION}.${GITCOUNT}"
#git add .
#git commit "Build ${APP_VERSION}.${GITCOUNT}"
#git checkout ${BRANCH}

#if [[ ${BRANCH}=="main" || ${BRANCH}=="test" ]]; then
#    echo "Poslat do GITHUBu."
#fi;

echo "RESTORE Application@id=${APP_ID} in manifest.xml and ${APP_FILE}"
git restore --staged manifest.xml ${APP_FILE}
git restore manifest.xml ${APP_FILE}

#git status
#git add .
#git commit -m "Build ${APP_VERSION}.${GITCOUNT}"

# TODO check restore
grep "iq:application id" manifest.xml
grep AppName ${APP_FILE}
grep version ${APP_FILE}