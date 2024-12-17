# Auto Theme Switcher

Auto Theme Switcher is a simple one-click tool that changes the theme of your Ubuntu system based on the time of the day. It uses the `gsettings` command to change the theme.
The scheduler script creates two cron job that runs the theme switcher script at sunrise and sunset at your timezone. It doesnot affect other cron jobs that you have set up. Duplicate runs of the scheduler script will not create duplicate cron jobs. Execution log is saved at project root.

## Installation

You may need to install `hdate` on your first run, instructions will be provided by the script. Or you can install it by running `sudo apt install hdate`.

## Usage

1. Change the `LATITUDE` and `LONGITUDE` values in **both** scripts to your location. You can find your location's latitude and longitude by searching for it on Google. The values should be in decimal format as shown in the script.
2. Change the `LIGHT_GTK_THEME`, `DARK_GTK_THEME`, `LIGHT_ICON_THEME` and `DAR_ICON_THEME` values in the `theme_switcher.sh` script to your desired light and dark themes. You can find the available themes by running `gsettings get org.gnome.desktop.interface gtk-theme`, `gsettings get org.gnome.desktop.interface icon-theme` in the terminal, donot forget to switch to the other theme in your system settings and then run it again to get the other theme name.

3. Change the `SCHEDULER_SCRIPT`,`SCHEDULER_LOG`,`THEME_SWITCHER_SCRIPT` and `THEME_SWITCHER_LOG` values in the scheduler script to the **absolute** path of the `scheduler.sh`, `theme_switcher.sh` scripts and their log files.

4. One click run: run the scheduler script once *(multiple runs do not create duplicates)* to create the cron jobs of both the scheduler and the theme switcher scripts:

    ``` 
    Checking dependencies... OK
    Today's sunrise: 07:59
    Today's sunset: 16:19
    Scheduler job doesn't exist. Adding it to crontab.
    Crontab updated with new sunrise and sunset jobs.
    Sunrise job: 07:59
    Sunset job: 16:19
    ```

    and you will see sth like this by running `crontab -l`:

    ```
    0 3 * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /bin/bash /home/enderwang/Documents/auto-theme-switcher/scheduler.sh >> /home/enderwang/Documents/auto-theme-switcher/scheduler.log 2>&1
    59 07 * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /bin/bash /home/enderwang/Documents/auto-theme-switcher/theme-switcher.sh  >> /home/enderwang/Documents/auto-theme-switcher/theme-switcher.log 2>&1
    19 16 * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus /bin/bash /home/enderwang/Documents/auto-theme-switcher/theme-switcher.sh  >> /home/enderwang/Documents/auto-theme-switcher/theme-switcher.log 2>&1
    ```

    - The first line is the cron job that runs the scheduler script every day at 3 am, 
    - the second line is the cron job that runs the theme switcher script at sunrise,
    - the third line is the cron job that runs the theme switcher script at sunset. 
    - Enjoy auto theme switching!
