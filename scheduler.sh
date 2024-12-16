#!/bin/bash

# Location (latitude and longitude):
LATITUDE="48.317009"
LONGITUDE="11.662260"

# Path to the theme-switcher script:
THEME_SWITCHER_SCRIPT="/home/enderwang/Documents/auto-theme-switcher/theme-switcher.sh"

# Check if `hdate` is installed
echo -n "Checking dependencies... "
[[ $(which hdate 2>/dev/null) ]] || { echo "hdate needs to be installed. Use 'sudo apt-get install hdate'"; exit 1; }
echo "OK"

# Get timezone offset
TIMEZONE_OFFSET=$(date +'%z' | sed -r 's/(.{3})/\1:/' | sed -r 's/([+-])(0)?(.*)/\1\3/')

# Fetch sunrise and sunset times using hdate
HDATE_OUTPUT=$(hdate -s --not-sunset-aware -l "$LATITUDE" -L "$LONGITUDE" -z"$TIMEZONE_OFFSET")
SUNRISE_TODAY=$(echo "$HDATE_OUTPUT" | grep "sunrise: " | grep -o '[0-2][0-9]:[0-6][0-9]')
SUNSET_TODAY=$(echo "$HDATE_OUTPUT" | grep "sunset: " | grep -o '[0-2][0-9]:[0-6][0-9]')

# Validate that times were fetched
if [[ -z "$SUNRISE_TODAY" || -z "$SUNSET_TODAY" ]]; then
    echo "Error: Unable to fetch sunrise/sunset times. Please check your hdate configuration."
    exit 1
fi

echo "Today's sunrise: $SUNRISE_TODAY"
echo "Today's sunset: $SUNSET_TODAY"

# Prepare cron times
SUNRISE_HOUR=$(echo "$SUNRISE_TODAY" | cut -d: -f1)
SUNRISE_MIN=$(echo "$SUNRISE_TODAY" | cut -d: -f2)

SUNSET_HOUR=$(echo "$SUNSET_TODAY" | cut -d: -f1)
SUNSET_MIN=$(echo "$SUNSET_TODAY" | cut -d: -f2)

# Backup existing crontab
crontab -l > ~/backup_crontab_$(date +%Y%m%d_%H%M%S).bak

# Create new crontab entry for sunrise and sunset
(
    # Keep existing cron jobs (except the theme-switcher jobs)
    crontab -l | grep -v "$THEME_SWITCHER_SCRIPT" || true

    # Add new sunrise job
    echo "$SUNRISE_MIN $SUNRISE_HOUR * * * /bin/bash $THEME_SWITCHER_SCRIPT"

    # Add new sunset job
    echo "$SUNSET_MIN $SUNSET_HOUR * * * /bin/bash $THEME_SWITCHER_SCRIPT"
) | crontab -

echo "Crontab updated with new sunrise and sunset jobs."
echo "Sunrise job: $SUNRISE_HOUR:$SUNRISE_MIN"
echo "Sunset job: $SUNSET_HOUR:$SUNSET_MIN"
