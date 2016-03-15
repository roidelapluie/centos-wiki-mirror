#!/bin/bash

set -x
set -e
git log --format=%ae|head -n 1|grep roidelapluie@inuits.eu||exit 0

./tmp.sh|tr "\n" "\0"|xargs -0 python update.py
