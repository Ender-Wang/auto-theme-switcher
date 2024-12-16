# Auto Theme Switcher

This is a simple script that changes the theme of your Ubuntu system based on the time of the day. It uses the `gsettings` command to change the theme.
The scheduler script creates two cron job that runs the theme switcher script at sunrise and sunset at your timezone. It doesnot affect other cron jobs that you have set up. Duplicate runs of the scheduler script will not create duplicate cron jobs.

## Installation

You may need to install `hdate` on your first run, instrcutions will be provided by the script. Or you can install it by running `sudo apt install hdate`.

## Usage

1. Change the `LATITUDE` and `LONGITUDE` variables in **both** scripts to your location. You can find your location's latitude and longitude by searching for it on Google. The values should be in decimal format as shown in the script.
2. Change the `LIGHT_GTK_THEME` and `DARK_GTK_THEME` variables in the `theme_switcher.sh` script to your desired light and dark themes. You can find the available themes by running `gsettings get org.gnome.desktop.interface gtk-theme`, `gsettings get org.gnome.desktop.interface icon-theme` in the terminal, donot forget to switch to the other theme in your system settings and then run it again to get the other theme name.

3. Change the `THEME_SWITCHER_SCRIPT` variable in the scheduler script to the **absolute** path of the `theme_switcher.sh` script.

4. Run the scheduler script manually to create the cron jobs and you will see sth like this by running `crontab -l`:

    ```
    58 07 * * * /bin/bash /home/enderwang/Documents/auto-theme-switcher/theme-switcher.sh
    19 16 * * * /bin/bash /home/enderwang/Documents/auto-theme-switcher/theme-switcher.sh
    ```

    The first line is the cron job that runs the theme switcher script at sunrise and the second line is the cron job that runs the theme switcher script at sunset.

5. Setup cron to run the scheduler script every day at 3 am. You can do this by running `crontab -e` and adding the following line:
    ```
    0 3 * * * /bin/bash /home/enderwang/Documents/auto-theme-switcher/theme-switcher-scheduler.sh
    ```
    This will run the scheduler script every day at 3 am. The scheduler script will then create the cron jobs for the theme switcher script to run at sunrise and sunset every day.
