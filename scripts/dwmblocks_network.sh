#!/bin/sh

status() {
    # Check for wired ethernet connection first
    ETHERNET_DEVICE=$(nmcli -t -f device,state dev status | grep 'eno1:connected' | cut -d ':' -f1)
    if [ -n "$ETHERNET_DEVICE" ]; then
        echo "󰛳 $ETHERNET_DEVICE"
    fi

    # If no ethernet, check for wifi
    WIFI_NAME=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d ':' -f2)
    if [ -n "$WIFI_NAME" ]; then
        SIGNAL=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d ':' -f2)
        # Using a more compact way to show signal strength
        if [ "$SIGNAL" -gt 80 ]; then
            ICON=" "
        elif [ "$SIGNAL" -gt 60 ]; then
            ICON=" "
        elif [ "$SIGNAL" -gt 40 ]; then
            ICON=" "
        else
            ICON=" "
        fi
        echo "$ICON $WIFI_NAME"
    else
			
        echo "  "
    fi
}

menu() {
    # This function is called on a mouse click
    CHOSEN=$(nmcli -t -f ssid dev wifi | dmenu -p "Connect to:")
    if [ -n "$CHOSEN" ]; then
        nmcli dev wifi connect "$CHOSEN"
        # Send a signal to refresh dwmblocks after connecting
        pkill -RTMIN+4 dwmblocks
    fi
}

# The `$BLOCK_BUTTON` variable is set by dwm when the block is clicked
if [ "$BLOCK_BUTTON" = "1" ]; then
    menu
else
    status
fi

