#!/bin/bash

ScriptHome=$(echo $HOME)
ScriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

verify_rom=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Verify saved ROM" )
verbose=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Verbose" )

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
  rom_savepath=$( _helpDefaultRead "ROM Savepath" )
  rom_readpath=$( _helpDefaultRead "ROM Readpath" )
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

function _get_chip_type()
{
  _set_programmer
  cd "$ScriptPath"/../bin/
  
  ./flashrom --programmer "$programmer" | grep -w "Found" > /private/tmp/flashtemp
  
  count=$( cat /private/tmp/flashtemp |wc -l |xargs )
  
  if [[ "$count" = 0 ]]; then
    _not_successful
  fi
  
  if [[ "$count" = 1 ]]; then
    _successful
    cat /private/tmp/flashtemp
  fi
  
  if [[ "$count" -gt 1 ]]; then
    _successful
    cat /private/tmp/flashtemp
    echo " "
    echo -e "\n#################### Attention! ###################"
    echo -e "Notice that it finds multiple versions of the chip.\nIf you are able to read the print on your chips,\nthere are numbers that match the output of the\nabove command. Mine had “MX25L3206E” printed on it."
    echo "###################################################"
    echo " "
  fi

  defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Types" "$count"
 
}

function _save_rom()
{
  _set_programmer
  echo -e "Saving ROM to: $rom_savepath\n"
  cd "$ScriptPath"/../bin/
  
  if [[ "$verbose" = "1" ]]; then
    ./flashrom -V --programmer "$programmer" -r "$rom_savepath"
  else
    ./flashrom --programmer "$programmer" -r "$rom_savepath"
  fi

  if [[ "$verify_rom" = "1" ]]; then
    if [[ "$verbose" = "1" ]]; then
      ./flashrom -V --programmer "$programmer" -v "$rom_savepath"
    else
      ./flashrom --programmer "$programmer" -v "$rom_savepath"
    fi
  fi

  if [[ "$?" = "0" ]]; then
    _successful
  else
    _not_successful
  fi
}

function _write_rom()
{
  _set_programmer
  
  verify_chip_type=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type" )
  chip_types=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Types" )

    if [[ "$chip_types" -gt "1" ]]; then
        echo -e "Flashing ROM from: $rom_readpath\n"
        cd "$ScriptPath"/../bin/
        if [[ "$chip_types" -gt "1" ]]; then
            if [[ "$verbose" = "1" ]]; then
              ./flashrom -V --programmer "$programmer" -w "$rom_readpath" -c "$verify_chip_type"
            else
              ./flashrom --programmer "$programmer" -w "$rom_readpath" -c "$verify_chip_type"
            fi
            if [[ "$?" = "0" ]]; then
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
              _successful
            else
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
              _not_successful
            fi
        else
            defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
            _not_successful
        fi
    else
        echo -e "Flashing ROM from: $rom_readpath\n"
        cd "$ScriptPath"/../bin/
            if [[ "$verbose" = "1" ]]; then
              ./flashrom -V --programmer "$programmer" -w "$rom_readpath"
            else
              ./flashrom --programmer "$programmer" -w "$rom_readpath"
            fi
            if [[ "$?" = "0" ]]; then
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
              _successful
            else
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
              _not_successful
            fi
        fi

}

function _erase_eeprom()
{
  _set_programmer
  
  verify_chip_type=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type" )
  chip_types=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Types" )

    cd "$ScriptPath"/../bin/

    if [[ "$chip_types" -gt "1" ]]; then
        if [[ "$chip_types" -gt "1" ]]; then
            if [[ "$verbose" = "1" ]]; then
              ./flashrom -V --programmer "$programmer" -c "$verify_chip_type" -E
            else
              ./flashrom --programmer "$programmer" -c "$verify_chip_type" -E
            fi
            if [[ "$?" = "0" ]]; then
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
              _successful
            else
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
              _not_successful
            fi
        else
            defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
            _not_successful
        fi
    else
            if [[ "$verbose" = "1" ]]; then
              ./flashrom -V --programmer "$programmer" -E
            else
              ./flashrom --programmer "$programmer" -E
            fi
            if [[ "$?" = "0" ]]; then
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
              _successful
            else
              defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
              _not_successful
            fi
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

function _detect_programmer()
{
  "$ScriptPath"/../bin/lsusb > /private/tmp/usbdetection
  devices=$( cat /private/tmp/usbdetection )
  rm /private/tmp/usbdetection

  if [[ $devices == *"1a86:5512"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "1"
  fi
  if [[ $devices == *"1443:0007"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "2"
  fi
  if [[ $devices == *"04d8:0033"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "3"
  fi
  if [[ $devices == *"09fb:6001"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "4"
  fi
  if [[ $devices == *"10c4:ea60"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "5"
  fi
  if [[ $devices == *"0483:dada"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "6"
  fi
  
}

$1
