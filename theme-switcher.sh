#!/bin/bash

# Location (latitude and longitude):
LATITUDE="48.317009"
LONGITUDE="11.662260"

# To see what theme/icon is currently enabled, execute this command:
# gsettings get org.gnome.desktop.interface gtk-theme
# gsettings get org.gnome.desktop.interface icon-theme
# Your themes for light (day) and dark (night) modes:
LIGHT_GTK_THEME="Yaru-purple"
DARK_GTK_THEME="Yaru-purple-dark"

LIGHT_ICON_THEME="Yaru-purple"
DARK_ICON_THEME="Yaru-purple-dark"


# Get the current timezone offset
TIMEZONE_OFFSET=$(date +'%z' | sed -r 's/(.{3})/\1:/' | sed -r 's/([+-])(0)?(.*)/\1\3/')

# Check if `hdate` is installed
echo -n "Checking dependencies... "
[[ $(which hdate 2>/dev/null) ]] || { echo "hdate needs to be installed. Use 'sudo apt install hdate'"; exit 1; }
echo "OK"

# Get sunrise and sunset times for today using hdate
HDATE_OUTPUT=$(hdate -s --not-sunset-aware -l "$LATITUDE" -L "$LONGITUDE" -z"$TIMEZONE_OFFSET")
SUNRISE_TODAY=$(echo "$HDATE_OUTPUT" | grep "sunrise: " | grep -o '[0-2][0-9]:[0-6][0-9]')
SUNSET_TODAY=$(echo "$HDATE_OUTPUT" | grep "sunset: " | grep -o '[0-2][0-9]:[0-6][0-9]')

echo "Today's sunrise: $SUNRISE_TODAY"
echo "Today's sunset: $SUNSET_TODAY"

# Get the current time
NOW=$(date +"%Y-%m-%d %H:%M:%S")
echo "Current date and time: $NOW"

# Convert times to comparable formats
COMPARABLE_NOW=$(date --date="$NOW" +%Y%m%d%H%M)
COMPARABLE_SUNRISE_TODAY=$(date --date="$SUNRISE_TODAY" +%Y%m%d%H%M)
COMPARABLE_SUNSET_TODAY=$(date --date="$SUNSET_TODAY" +%Y%m%d%H%M)

# Determine if it's day or night and set the theme accordingly
if [ "$COMPARABLE_NOW" -gt "$COMPARABLE_SUNRISE_TODAY" ] && [ "$COMPARABLE_NOW" -lt "$COMPARABLE_SUNSET_TODAY" ]; then
    echo "Setting day theme..."
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme "$LIGHT_GTK_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "$LIGHT_ICON_THEME"
    echo "Day theme has been set"
    NEXT_EXECUTION_AT=$(date --date="$SUNSET_TODAY 1 minute" +"%Y-%m-%d %H:%M")
else
    echo "Setting night theme..."
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme "$DARK_GTK_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "$DARK_ICON_THEME"
    echo "Night theme has been set"
fi
