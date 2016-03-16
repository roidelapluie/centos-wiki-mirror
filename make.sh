#!/bin/bash
set -e
mkdir -p wiki
set -o pipefail
CURL(){
    sleep 4
    curl -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0' "$@"
}
git config user.name "Automation script"||true
git config user.email jenkins@roidelapluie.be||true
CURL https://wiki.centos.org/?action=titleindex|
grep ^SpecialInterestGroup/ConfigManagementSIG|
while read page
do
    page=$(echo $page|tr -dc A-Za-z0-9/)
    echo $page
    mkdir -p "wiki/$(dirname $page)"
    cat DISCLAIMER > "wiki/${page}.moin"
    echo "- Original page: https://wiki.centos.org/${page}" >> "wiki/${page}.moin"
    echo "- Authors: https://wiki.centos.org/${page}?action=info" >> "wiki/${page}.moin"
    echo >> "wiki/${page}.moin"
    if which busybox
    then
        d2u='busybox dos2unix'
    else
        d2u=dos2unix
    fi
    echo '---' >> "wiki/${page}.moin"
    CURL "https://wiki.centos.org/${page}?action=raw" | $d2u >> "wiki/${page}.moin"
    md5sum < "wiki/${page}.moin" > "wiki/${page}.md5"
    if [[ $(git diff|wc -l) -gt 0 ]] || ! git --no-pager blame "wiki/${page}.moin"
    then
      git add "wiki/${page}.moin"||true
      git add "wiki/${page}.md5"||true
      git commit -m "Update $page"
    fi
done
