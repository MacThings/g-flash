#!/bin/bash

ScriptHome=$(echo $HOME)
ScriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

verify_rom=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Verify saved ROM" )
verbose=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Verbose" )
download_path=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Download Path" )

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
  elif [[ $programmer -gt "6" ]] && [[ $programmer -lt "22" ]]; then
    programmer="ft2232_spi"
  elif [[ $programmer = "22" ]]; then
    programmer="stlinkv3_spi"
  fi
  
  
  if [[ $a -gt "6" ]] && [[ $programmer -lt "22" ]]; then
  echo "beide"
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
  #count="10"
  
  if [[ "$count" = 0 ]]; then
    _not_successful
  fi
  
  if [[ "$count" = 1 ]]; then
    _successful
    #cat /private/tmp/flashtemp
    chip_type=$( cat /private/tmp/flashtemp |sed -e 's/.*\ "//g' -e 's/".*//g' |xargs )
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type" "\"$chip_type\""
  fi
  
  if [[ "$count" > 1 ]]; then
    _successful
    cat /private/tmp/flashtemp
    echo " "
    echo -e "\n#################### Attention! ###################"
    echo -e "Notice that it finds multiple versions of the chip. If you are able to read the print on your chips,\nthere are numbers that match the output of the above command. Mine had “MX25L3206E” printed on it."
    echo "###################################################"
    echo " "
  fi

  defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Types" "$count"
 
}

function _save_rom()
{
  _set_programmer
  
  chip_type=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type" )
  
  echo -e "Saving ROM to: $rom_savepath\n"
  cd "$ScriptPath"/../bin/
  
  if [[ "$verbose" = "1" ]]; then
    ./flashrom -V --programmer "$programmer" -r "$rom_savepath" -c "$chip_type"
  else
    ./flashrom --programmer "$programmer" -r "$rom_savepath" -c "$chip_type"
  fi
  if [[ "$?" = "0" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
    _successful
  else
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
    _not_successful
  fi

  if [[ "$verify_rom" = "1" ]]; then
    if [[ "$verbose" = "1" ]]; then
      ./flashrom -V --programmer "$programmer" -v "$rom_savepath" -c "$chip_type"
    else
      ./flashrom --programmer "$programmer" -v "$rom_savepath" -c "$chip_type"
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

function _write_rom()
{
  _set_programmer
  
  chip_type=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type" )

        echo -e "Flashing ROM from: $rom_readpath\n"
        cd "$ScriptPath"/../bin/
        if [[ "$verbose" = "1" ]]; then
          ./flashrom -V --programmer "$programmer" -w "$rom_readpath" -c "$chip_type"
        else
          ./flashrom --programmer "$programmer" -w "$rom_readpath" -c "$chip_type"
        fi
        if [[ "$?" = "0" ]]; then
          defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
          _successful
        else
          defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
          _not_successful
        fi
}

function _erase_eeprom()
{
  _set_programmer
  
 chip_type=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type" )

    cd "$ScriptPath"/../bin/
    if [[ "$verbose" = "1" ]]; then
        ./flashrom -V --programmer "$programmer" -c "$chip_type" -E
    else
        ./flashrom --programmer "$programmer" -c "$chip_type" -E
    fi
    if [[ "$?" = "0" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool false
        _successful
    else
        defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Chip Type Mismatch" -bool true
       _not_successful
    fi
}

function _list_usb_devices()
{
  "$ScriptPath"/../bin/lsusb_list
}

function _check_programmer()
{
  programmer=$( _helpDefaultRead "Programmer" )
  if [[ $programmer = "1" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "1a86:5512" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
      touch /private/tmp/devok
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
  if [[ $programmer = "7" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "15ba:002a" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "8" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "15ba:002b" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "9" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "15ba:0004" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "10" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "15ba:0003" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "11" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "1457:5118" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "12" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "18d1:5003" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "13" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "18d1:5002" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "14" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "18d1:5001" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "15" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "096c:1449" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "16" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0403:cff8" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "17" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0403:8a99" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "18" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0403:8a98" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "19" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0403:6014" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "20" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0403:6011" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "21" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0403:6010" > /dev/null
    if [ $? = 0 ]; then
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool true
    else
      defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer found" -bool false
    fi
  fi
  if [[ $programmer = "22" ]]; then
    "$ScriptPath"/../bin/lsusb |grep "0483:374f" > /dev/null
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
  elif [[ $devices == *"1443:0007"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "2"
  elif [[ $devices == *"04d8:0033"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "3"
  elif [[ $devices == *"09fb:6001"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "4"
  elif [[ $devices == *"10c4:ea60"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "5"
  elif [[ $devices == *"0483:dada"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "6"
  elif [[ $devices == *"15ba:002a"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "7"
  elif [[ $devices == *"15ba:002b"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "8"
  elif [[ $devices == *"15ba:0004"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "9"
  elif [[ $devices == *"15ba:0003"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "10"
  elif [[ $devices == *"1457:5118"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "11"
  elif [[ $devices == *"18d1:5003"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "12"
  elif [[ $devices == *"18d1:5002"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "13"
  elif [[ $devices == *"18d1:5001"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "14"
  elif [[ $devices == *"096c:1449"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "15"
  elif [[ $devices == *"0403:cff8"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "16"
  elif [[ $devices == *"0403:8a99"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "17"
  elif [[ $devices == *"0403:8a98"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "18"
  elif [[ $devices == *"0403:6014"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "19"
  elif [[ $devices == *"0403:6011"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "20"
  elif [[ $devices == *"0403:6010"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "21"
  elif [[ $devices == *"0483:374f"* ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Programmer" "22"
  fi
}

function _download_wine()
{
  mkdir "$download_path"/G-Flash > /dev/null
  rm -rf "$download_path"/G-Flash/PhoenixTool.app > /dev/null
  curl -q https://www.sl-soft.de/extern/g-flash/PhoenixTool.7z > "$download_path"/G-Flash/PhoenixTool.7z
  "$ScriptPath"/../bin/7za x -y -bsp0 -bso0 "$download_path"/G-Flash/PhoenixTool.7z -o"$download_path"/G-Flash
  if [[ "$?" = "0" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Successful" -bool true
    rm "$download_path"/G-Flash/PhoenixTool.7z
  fi
}

function _download_phoenixtool()
{
  mkdir "$download_path"/G-Flash > /dev/null
  rm -rf "$download_path"/G-Flash/PhoenixTool-Win > /dev/null
  curl -q https://www.sl-soft.de/extern/g-flash/PhoenixTool-Win.zip > "$download_path"/G-Flash/PhoenixTool-Win.zip
  #"$ScriptPath"/../bin/7za x -y -bsp0 -bso0 "$download_path"/G-Flash/PhoenixTool-Win.zip -o"$download_path"/G-Flash
  if [[ "$?" = "0" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Successful" -bool true
    #rm "$download_path"/G-Flash/PhoenixTool-Win.zip
    #rm -rf "$download_path"/G-Flash/__MACOSX
  fi
}

function _download_mods()
{

  model=$( defaults read "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Model" )
    
  mkdir "$download_path"/G-Flash > /dev/null
  rm -rf "$download_path"/G-Flash/bios_mod_bundle.zip > /dev/null
  curl https://www.sl-soft.de/extern/g-flash/bios_mod_bundle.zip > "$download_path"/G-Flash/bios_mod_bundle.zip
  "$ScriptPath"/../bin/7za x -y -bsp0 -bso0 "$download_path"/G-Flash/bios_mod_bundle.zip "$model" "Modules.txt" -o"$download_path"/G-Flash
  if [[ "$?" = "0" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/gflash.slsoft.de.plist" "Successful" -bool true
    rm "$download_path"/G-Flash/bios_mod_bundle.zip
    rm -rf "$download_path"/G-Flash/__MACOSX
  fi
  
}

$1
