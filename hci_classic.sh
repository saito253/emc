#!/bin/bash

# hcitool, hciconfig, hciattach

sudo ifconfig wlan0 down
sudo ./wl down

sudo hciconfig hci0 down 			        # command to disable the HCI
# Command BlueZ Format: hcitool cmd OGF OCF Parameter(s)
sudo hciconfig hci0 up 				        # command to enable the HCI
sudo hcitool -i hci0 cmd 0x03 0x003 		# HCI_Reset 
sudo hcitool -i hci0 cmd 0x03 0x01A 0x034	# HCI_Set_Event_Filter 
sudo hcitool -i hci0 cmd 0x06 0x003 		# HCI_Enable_Device_Under_Test_Mode 

#sudo hcitool cmd 0x03 0x0C 0x00 			# HCI_Reset
#sudo hcitool cmd 0x05 0x0C 0x03 0x021 0x002 0x023 	#HCI_Set_Event_Filter 
#sudo hcitool cmd 0x1A 0x0C 0x01 0x034 		# HCI_Write_Scan_Enable 
#sudo hcitool cmd 0x03 0x18 0x00 		    # HCI_Enable_Device_Under_Test_Mode
#sudo hcitool -i hci0 cmd 0x03 0x002D $pw	# HCI_Read_Transmit_Power_Level
#sudo hcitool -i hci0 cmd 0x3f 0x00 0x0$pw	# HCI_EXT_SetTxPowerCmd
#sudo hcitool inqtpl pw
#sudo hciconfig ptype=$ptype 			    # Packet type: DM1 DM3 DM5 DH1 DH3 DH5 HV1 HV2 HV3

BDADDR=`sudo hcitool -i hci0 dev | nawk '/hci0/{print $2}'`
echo $BDADDR


# --------------- defualt settings ----------------
trx=tx             # tx or rx
mode=0x01          # 0x00:79hop, 0x01: single, 0x02: fixed
ch=0x4e            # 0x00:2402MHz - 0x4E:2480MHz
modu=0x03          # 0x03:0xAA, 0x04:PRBS9 Pattern
logi=0x00          # 0x00:ACL EDR, 0x01:ACL Basic
pkt=0x04           # 0x00:null,0x01:poll,0x02:fhs,0x03:dm1,0x04:dh1,0x05:vh1,0x06:vh2,0x07:vh3,0x08:dv,0x09:aux1,0x0a:dm3,0x0b:dh3,0x0c:ev4,0x0d:ev5,0x0e:dm5,0x0f:dh5
plen="0x1b 0x00"   # dh1:(27)0x1b 0x00,dh3:(183)0xb7 0x00,dh5:(339)0x53 0x01,2DH1:(54)0x36 0x00,2DH3:(367)0x6f 0x03,2DH5:(679)0xa7 0x02,3DH1:(83)0x53 0x00,3DH3:(552)0x28 0x02,3DH5(1021)0xfd 0x03
txpw=0x08          # 0x00:0dBm,0x01:-4dBm,0x02:-8dBm,0x03:-12dBm,0x04:-16dBm,0x05:-20dBm,0x06:-24dBm,0x07:-28dBm,0x08:specify power in dBn,0x09:specify power Table index
trpw=0xfc
# -------------------------------------------------

echo -n INPUT_TRX[tx.rx]
read trx

if [ $trx = "tx" ]; then
#echo -n INPUT_MODE[0x00:79 channel, 0x01:single, 0x02:fixed]
echo -n INPUT_MODE[0x00:79 channel, 0x01:single]:
read mode
fi

#echo -n INPUT_PACKET_TYPE[0x00:null,0x01:poll,0x02:fhs,0x03:dm1,0x04:dh1,0x05:vh1,0x06:vh2,0x07:vh3,0x08:dv,0x09:aux1,0x0a:dm3,0x0b:dh3,0x0c:ev4,0x0d:ev5,0x0e:dm5,0x0f:dh5]:
#read pkt
echo -n INPUT_CHANNEL[0x00:2402MHz - 0x27:2441MHz - 0x2e:2448MHz - 0x4e:2480MHz]:
read ch

if [ $trx = "tx" ]; then
#echo -n INPUT_POWER[0x00:0dBm,0x01:-4dBm,0x02:-8dBm,0x03:-12dBm,0x04:-16dBm,0x05:-20dBm,0x06:-24dBm,0x07:-28dBm,0x08:specify power in dBn, 0x09: specify power Table index]
echo -n INPUT_POWER[0x00:0dBm,0x01:-4dBm,0x02:-8dBm,0x03:-12dBm,0x04:-16dBm,0x05:-20dBm,0x06:-24dBm,0x07:-28dBm]:
read txpw
fi

echo -n INPUT_PACKET_TYPE[DH1,DH3,DH5,2DH1,2DH3,2DH5,3DH1,3DH3,3DH5]:
read pkt_typ

if [ $pkt_typ = "DH1" ]; then
  pkt="0x04"
  plen="0x1b 0x00"
elif [ $pkt_typ = "DH3" ]; then
  pkt="0x0b"
  plen="0xb7 0x00"
elif [ $pkt_typ = "DH5" ]; then
  pkt="0x0f"
  plen="0x53 0x01"
elif [ $pkt_typ = "2DH1" ]; then
  pkt="0x04"
  plen="0x36 0x00"
elif [ $pkt_typ = "2DH3" ]; then
  pkt="0x0a"
  plen="0x6f 0x01"
elif [ $pkt_typ = "2DH5" ]; then
  pkt="0x0e"
  plen="0xa7 0x02"
elif [ $pkt_typ = "3DH1" ]; then
  pkt="0x08"
  plen="0x53 0x00"
elif [ $pkt_typ = "3DH3" ]; then
  pkt="0x0b"
  plen="0x28 0x02"
elif [ $pkt_typ = "3DH5" ]; then
  pkt="0x0f"
  plen="0xfd 0x03"
else
  plen="0x00 0x00"
fi

#Note: When intends to give specific power level in dBm, set Param8=0x8 and specify Param9
#with a value in range of �]127 ~ +128. For example, �]4dBm (Param9=0xFC), �]5dBm
#(Param9=0xFB), �]6dBm (Param9=0xFA), etc.

if [ $txpw = "0x08" ]; then
  trpw="0xfc"
elif [ $txpw = "0x09" ]; then
  trpw="0xfc"
fi

echo "-------------- Input summary ------------"
echo "Operation Moder:"$mode
echo "Channel Number: "$ch
echo "Modulation:     "$modu
echo "Logical Channel:"$logi
echo "Packet Type:    "$pkt
echo "Packet Length:  "$plen
echo "Tx Power:       "$txpw
echo "Transmit Power: "$trpw
echo "-----------------------------------------"

# LE Transmitter Test
#sudo hcitool -i hci0 cmd 0x08 0x1e 0x0$ch 0x03 0x07

#51 FC 10 06 05 04 03 02 01 00 00 04 01 0F 00 00 00 00 00
#52 FC 0E 06 05 04 03 02 01 E8 03 00 04 01 0F 00 00       E8 03 : report perirod
#BD ADDR: ee ff c0 bb 00 00
if [ $trx = "tx" ]; then
   sudo hcitool -i hci0 cmd 0x3F 0x051 0xee 0xff 0xc0 0xbb 0x00 0x00 $mode $ch $modu $logi $pkt $plen $txpw $trpw 0x00
elif [ $trx = "rx" ]; then
   sudo hcitool -i hci0 cmd 0x3F 0x052 0xee 0xff 0xc0 0xbb 0x00 0x00 0xe8 0x03 $ch $modu $logi $pkt $plen
fi
#sudo hcitool -i hci0 cmd 0x3F 0x051 0xee 0xff 0xc0 0x88 0x00 0x00 0x01 0x13 0x04 0x01 0x0F 0x53 0x01 0x09 0x00 0x00
#sudo hcitool cmd 0x51 0xFC 0x10 0x66 0x55 0x44 0x33 0x22 0x11 0x01 0x00 0x04 0x01 0x0F 0x00 0x00 0x09 0x00 0x00
#sudo hcitool -i hci0 cmd 0x08 0x1e 0x00 0x51 0xFC 0x10 0x66 0x55 0x44 0x33 0x22 0x11 0x01 0x00 0x03 0x01 0x03 0x11
#sudo hcitool -i hci0 cmd 0x08 0x0008 1e 02 01 1a 1a ff 4c 00 02 15 e2 c5 6d b5 df fb 48 d2 b0 60 d0 f5 a7 10 96 e0 00 00 00 00 c5 00 00 00 00 00 00 00 00 00 00 00 00 00
#sudo hcitool cmd 0x03 0x03
#sudo hcitool cmd 0x08 0x1e 0x10 0x0

# Rx test
#sudo hcitool -i hci0 cmd 0x3F 0x052 0x06 0x05 0x04 0x03 0x02 0x01 0xE8 0x03 0x00 0x04 0x01 0x0F 0xFF 0xFF


exit
