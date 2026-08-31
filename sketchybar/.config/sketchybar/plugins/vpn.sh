#!/usr/bin/env bash

# scutil can keep reporting a VPN as "Connected" even after it's paused or
# disabled (NordVPN leaves its NEVPNManager session marked connected either
# way), so this checks actual tunnel interfaces instead of trusting scutil's
# status. Tailscale's tunnel IP is always in the CGNAT range (100.64.0.0/10);
# any other tunnel interface with a real IPv4 address is attributed to
# whichever non-Tailscale VPN scutil currently lists as connected.
is_cgnat() {
    local o1 o2 o3 o4
    IFS=. read -r o1 o2 o3 o4 <<< "$1"
    [ "$o1" = "100" ] && [ "$o2" -ge 64 ] 2>/dev/null && [ "$o2" -le 127 ] 2>/dev/null
}

TUNNEL_IPS=$(for iface in $(ifconfig -l); do
    echo "$iface" | grep -qE '^(utun|ppp)' || continue
    ifconfig "$iface" 2>/dev/null | awk '/inet /{print $2}'
done)

TAILSCALE_UP=false
OTHER_VPN_UP=false
while IFS= read -r ip; do
    [ -z "$ip" ] && continue
    if is_cgnat "$ip"; then
        TAILSCALE_UP=true
    else
        OTHER_VPN_UP=true
    fi
done <<< "$TUNNEL_IPS"

NAMES=""
[ "$TAILSCALE_UP" = true ] && NAMES="Tailscale"

if [ "$OTHER_VPN_UP" = true ]; then
    OTHER_NAME=$(scutil --nc list 2>/dev/null | grep '(Connected)' | grep -v '"Tailscale"' | sed -E 's/.*"([^"]+)".*/\1/' | sed -E 's/ - .*//' | head -1)
    [ -z "$OTHER_NAME" ] && OTHER_NAME="VPN"
    if [ -n "$NAMES" ]; then
        NAMES="$NAMES, $OTHER_NAME"
    else
        NAMES="$OTHER_NAME"
    fi
fi

if [ -z "$NAMES" ]; then
    sketchybar --set $NAME drawing=off
    exit 0
fi

sketchybar --set $NAME drawing=on label="$NAMES"
