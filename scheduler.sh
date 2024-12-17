#!/bin/bash

# Location (latitude and longitude):
LATITUDE="48.317009"
LONGITUDE="11.662260"

# Path to the theme-switcher script and log, scheduler script and log:
THEME_SWITCHER_SCRIPT="/home/enderwang/Documents/auto-theme-switcher/theme-switcher.sh"
THEME_SWITCHER_LOG="/home/enderwang/Documents/auto-theme-switcher/theme-switcher.log"
SCHEDULER_SCRIPT="/home/enderwang/Documents/auto-theme-switcher/scheduler.sh"
SCHEDULER_LOG="/home/enderwang/Documents/auto-theme-switcher/scheduler.log"

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


# Fetch DISPLAY and DBUS_SESSION_BUS_ADDRESS
# If DISPLAY is empty, set it to :0
if [[ -z "$DISPLAY_VALUE" ]]; then
    DISPLAY_VALUE=":0"
fi
DBUS_SESSION_BUS_ADDRESS_VALUE=$(echo $DBUS_SESSION_BUS_ADDRESS)

# Backup existing crontab
crontab -l > ~/backup_crontab_$(date +%Y%m%d_%H%M%S).bak

# Add the scheduler to run every day at 3 AM if it doesn't already exist
CRON_ENTRY="0 3 * * * DISPLAY=$DISPLAY_VALUE DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS_VALUE /bin/bash $SCHEDULER_SCRIPT >> $SCHEDULER_LOG 2>&1"
if ! crontab -l | grep -q "$SCHEDULER_SCRIPT"; then
    echo "Scheduler job doesn't exist. Adding it to crontab."
    (
        # Keep existing cron jobs (except the scheduler script)
        crontab -l | grep -v "$SCHEDULER_SCRIPT" || true

        # Add new scheduler job
        echo "$CRON_ENTRY"
    ) | crontab -
else
    echo "Scheduler script already exists in crontab."
fi

# Create new crontab entry for sunrise and sunset
(
    # Keep existing cron jobs (except the theme-switcher jobs)
    crontab -l | grep -v "$THEME_SWITCHER_SCRIPT" || true

    # Add new sunrise job
    echo "$SUNRISE_MIN $SUNRISE_HOUR * * * DISPLAY=$DISPLAY_VALUE DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS_VALUE /bin/bash $THEME_SWITCHER_SCRIPT  >> $THEME_SWITCHER_LOG 2>&1"

    # Add new sunset job
    echo "$SUNSET_MIN $SUNSET_HOUR * * * DISPLAY=$DISPLAY_VALUE DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS_VALUE /bin/bash $THEME_SWITCHER_SCRIPT  >> $THEME_SWITCHER_LOG 2>&1"
) | crontab -

echo "Crontab updated with new sunrise and sunset jobs."
echo "Sunrise job: $SUNRISE_HOUR:$SUNRISE_MIN"
echo "Sunset job: $SUNSET_HOUR:$SUNSET_MIN"
