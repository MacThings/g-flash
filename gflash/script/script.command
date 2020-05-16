#!/bin/bash

ScriptHome=$(echo $HOME)
ScriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function _helpDefaultWrite()
{
    VAL=$1
    local VAL1=$2

    if [ ! -z "$VAL" ] || [ ! -z "$VAL1" ]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "$VAL" "$VAL1"
    fi
}

function _helpDefaultRead()
{
    VAL=$1

    if [ ! -z "$VAL" ]; then
    defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "$VAL"
    fi
}

function _loaded()
{
  cd "$ScriptPath"/../bin/
  ./flashrom --programmer ch341a_spi -r toll
}

$1
