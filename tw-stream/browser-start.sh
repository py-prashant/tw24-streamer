#!/usr/bin/env bash

# Cleanup chrome crash status
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' '~/.config/chromium/Default/Preferences'
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' '~/.config/chromium/Default/Preferences'


export DISPLAY=:0
sleep 15
while true
do
	pkill chromium
	sleep 1
	chromium-browser --start-maximized --kiosk --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland <link> &
	sleep 120

done