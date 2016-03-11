#!/bin/bash
set -e
mkdir -p tmp
set -o pipefail
CURL(){
    curl -s -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0' "$@"
}
git config user.name "Automation script"||true
git config user.email jenkins@roidelapluie.be||true
CURL https://wiki.centos.org/?action=titleindex|
grep ^SpecialInterestGroup/ConfigManagementSIG|
while read page
do
    page=$(echo $page|tr -dc A-Za-z0-9/)
    mkdir -p "tmp/$(dirname $page)"
    cat DISCLAIMER > "tmp/${page}.moin"
    echo "- Original page: https://wiki.centos.org/${page}" >> "tmp/${page}.moin"
    echo "- Authors: https://wiki.centos.org/${page}?action=info" >> "tmp/${page}.moin"
    echo >> "tmp/${page}.moin"
    if which busybox &>/dev/null
    then
        d2u='busybox dos2unix'
    else
        d2u=dos2unix
    fi
    echo '---' >> "tmp/${page}.moin"
    CURL "https://wiki.centos.org/${page}?action=raw" | $d2u >> "tmp/${page}.moin"
    md5sum < "tmp/${page}.moin" > "tmp/${page}.md5"
    if [[ "$(md5sum < "tmp/${page}.md5")" != "$(md5sum < "wiki/${page}.md5")" ]]
    then
        echo $page: bad page >&2
    elif [[ "$(md5sum < "tmp/${page}.moin")" != "$(md5sum < "wiki/${page}.moin")" ]]
    then
      git add "wiki/${page}.moin"||true
      git add "wiki/${page}.md5"||true
      echo $page
    fi
done
