#!/bin/bash

# Returns the IP of the first active ethernet (non-WiFi, non-Thunderbolt) interface
get_lan_ip() {
  networksetup -listallhardwareports | awk '
    /Hardware Port:/ { port = $0 }
    /Device:/        { dev = $2 }
    /Ethernet Address:/ {
      if (port !~ /Wi-Fi|Thunderbolt|Bridge/) print dev
    }
  ' | while read -r iface; do
    IP=$(ipconfig getifaddr "$iface" 2>/dev/null)
    if [ -n "$IP" ]; then echo "$IP"; return; fi
  done
}

update() {
  source "$CONFIG_DIR/icons.sh"
  WIFI_IP="$(ipconfig getifaddr en0 2>/dev/null)"
  SSID="$(networksetup -listpreferredwirelessnetworks en0 2>/dev/null | grep -v '^Preferred' | head -1 | xargs)"

  if [ -n "$WIFI_IP" ]; then
    ICON="$WIFI_CONNECTED"
    LABEL="$SSID"
  else
    LAN_IP="$(get_lan_ip)"
    if [ -n "$LAN_IP" ]; then
      ICON="$LAN_CONNECTED"
      LABEL="Ethernet"
    else
      ICON="$WIFI_DISCONNECTED"
      LABEL="Disconnected"
    fi
  fi

  sketchybar --set $NAME icon="$ICON" label="$LABEL"
}

click() {
  source "$CONFIG_DIR/icons.sh"
  WIFI_IP="$(ipconfig getifaddr en0 2>/dev/null)"
  CURRENT="$(sketchybar --query $NAME | jq -r .label.value)"

  if [ -n "$WIFI_IP" ]; then
    SSID="$(networksetup -listpreferredwirelessnetworks en0 2>/dev/null | grep -v '^Preferred' | head -1 | xargs)"
    if [ "$CURRENT" = "$WIFI_IP" ]; then
      sketchybar --set $NAME label="$SSID"
    else
      sketchybar --set $NAME label="$WIFI_IP"
    fi
  else
    LAN_IP="$(get_lan_ip)"
    if [ -n "$LAN_IP" ]; then
      if [ "$CURRENT" = "$LAN_IP" ]; then
        sketchybar --set $NAME label="Ethernet"
      else
        sketchybar --set $NAME label="$LAN_IP"
      fi
    fi
  fi
}

case "$SENDER" in
  "wifi_change") update
  ;;
  "mouse.clicked") click
  ;;
esac
