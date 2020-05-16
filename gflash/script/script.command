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

function _set_programmer()
{
  rom_path=$( _helpDefaultRead "ROM Savepath" )
  programmer=$( _helpDefaultRead "Programmer" )
  if [[ $programmer = "1" ]]; then
    programmer="ch341a_spi"
  elif [[ $programmer = "2" ]]; then
    programmer="digilent_spi"
  elif [[ $programmer = "3" ]]; then
    programmer="pickit2_spi "
  elif [[ $programmer = "4" ]]; then
    programmer="usbblaster_spi"
  elif [[ $programmer = "5" ]]; then
    programmer="developerbox"
  elif [[ $programmer = "6" ]]; then
    programmer="dediprog"
  fi
}

function _successful()
{
  defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Successful" -bool true
}

function _not_successful()
{
  defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Successful" -bool false
}

function _save_rom()
{
  _set_programmer
  echo -e "Writing ROM to: $rom_path\n"
  cd "$ScriptPath"/../bin/
  ./flashrom --programmer "$programmer" -r "$rom_path"
  if [[ "$?" = "0" ]]; then
    _successful
  else
    _not_successful
  fi
}

function _list_usb_devices()
{
  "$ScriptPath"/../bin/lsusb
}

function _check_programmer()
{
  programmer=$( _helpDefaultRead "Programmer" )
  if [[ $programmer = "1" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "1a86:5512" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  
  if [[ $programmer = "2" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "1443:0007" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  
  if [[ $programmer = "3" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "04d8:0033" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  
  if [[ $programmer = "4" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "09fb:6001" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  
  if [[ $programmer = "5" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "10c4:ea60" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  
  if [[ $programmer = "6" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0483:dada" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
}

$1
