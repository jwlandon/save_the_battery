# Save the Battery

## Battery Care Background
Take better care of your Linux laptop battery by not letting it over-charge!  By default, systems are generally configured to begin charging at any time and continuously charge until the battery reaches 100%.  While this is a good strategy to use when you're getting ready to use your laptop away from a power source, it is not good practice when your laptop is indefinitely docked. 

### Battery Maintenance: Key Do's and Dont's 
1. Ideally, keep the battery between 20 and 80%
2. Avoid leaving the battery fully charged for extended periods
3. Never over-charge the battery
4. Target a 50% charge when storing your laptop (or the battery) for an extended duration.
5. Avoid fully discharging the battery

## Set Appropriate Target Levels
This repository contains a script called set_charge_levels.sh which is used to set the maximum charge levels of your battery to a given percentage of charge.  The script also allows for the minimum battery level before a charge can accepted.  Together, this allows your battery to be kept between a min and max levels.   And when combined with rc.local, your battery is assured of never being left in a full state for extended periods.

## Usage
```
./set_charge_level.sh --start <level> --stop <level>

# set point at which the battery will begin charging
./set_charge_level.sh --start 50
2024-12-26 18:28:01 INFO Using /sys/class/power_supply/BAT0
2024-12-26 18:28:01 INFO Setting minimum battery level 50 (before the battery accepts a charge)
2024-12-26 18:28:01 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_start_threshold reports 50 ; success setting value
2024-12-26 18:28:01 INFO Stop charge level action not called ; value currently set to 80

# set point at which the battery will halt charging
./set_charge_level.sh --stop 85
2024-12-26 18:29:01 INFO Using /sys/class/power_supply/BAT0
2024-12-26 18:29:01 INFO Start charge level action not called ; value currently set at 50
2024-12-26 18:29:01 INFO Setting maximum battery level 85 (before the battery stops accepting a charge)
2024-12-26 18:29:01 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_end_threshold reports 85 ; success setting value

# set both simultaneously
./set_charge_level.sh --start 75 --stop 80
2024-12-26 18:30:32 INFO Using /sys/class/power_supply/BAT0
2024-12-26 18:30:32 INFO Setting minimum battery level 75 (before the battery accepts a charge)
2024-12-26 18:30:32 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_start_threshold reports 75 ; success setting value
2024-12-26 18:30:32 INFO Setting maximum battery level 80 (before the battery stops accepting a charge)
2024-12-26 18:30:32 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_end_threshold reports 80 ; success setting value

```

# Installation notes for Ubuntu
## Copy the script to /etc/batt_mgmt/ and set exec permissions 
```
$ mkdir /etc/batt_mgmt
$ cp /path/to/set_charge_level.sh /etc/batt_mgmt/
$ chmod +x /etc/batt_mgmt/set_charge_level.sh
```
## If it doesn't already exist, copy the following service file into /etc/systemd/system/rc-local.service
```
$ cat /etc/systemd/system/rc-local.service
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes

[Install]
 WantedBy=multi-user.target

```
## Sample /etc/rc.local file
```
$ cat /etc/rc.local 
#!/bin/bash
# Start up scripts below

# set battery start and stop charge levels
/etc/batt_mgmt/set_charge_levels.sh --stop 80 --start 75

exit 0

```
## Enable and start the rc-local service
```
$ systemctl enable rc-local
Created symlink /etc/systemd/system/multi-user.target.wants/rc-local.service → /etc/systemd/system/rc-local.service.

$ systemctl start rc-local

# check status to ensure it started
$ systemctl status rc-local
● rc-local.service - /etc/rc.local Compatibility
     Loaded: loaded (/etc/systemd/system/rc-local.service; enabled; preset: enabled)
    Drop-In: /usr/lib/systemd/system/rc-local.service.d
             └─debian.conf
     Active: active (exited) since Thu 2024-12-26 18:52:04 PST; 5s ago
    Process: 9525 ExecStart=/etc/rc.local start (code=exited, status=0/SUCCESS)
        CPU: 16ms

Dec 26 18:52:04 J-ThinkPad systemd[1]: Starting rc-local.service - /etc/rc.local Compatibility...
Dec 26 18:52:04 J-ThinkPad rc.local[9526]: 2024-12-26 18:52:04 INFO Using /sys/class/power_supply/BAT0
Dec 26 18:52:04 J-ThinkPad rc.local[9526]: 2024-12-26 18:52:04 INFO Setting minimum battery level 75 (before the battery accepts a charge)
Dec 26 18:52:04 J-ThinkPad rc.local[9526]: 2024-12-26 18:52:04 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_start_threshold reports 75 ; success setting value
Dec 26 18:52:04 J-ThinkPad rc.local[9526]: 2024-12-26 18:52:04 INFO Setting maximum battery level 80 (before the battery stops accepting a charge)
Dec 26 18:52:04 J-ThinkPad rc.local[9526]: 2024-12-26 18:52:04 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_end_threshold reports 80 ; success setting value
Dec 26 18:52:04 J-ThinkPad systemd[1]: Started rc-local.service - /etc/rc.local Compatibility.

```

## Sample journal messaging if rc-local service is enabled (Ubuntu)
```
$ journalctl -u rc-local -S "2 hours ago"
Dec 26 16:20:26 J-ThinkPad systemd[1]: Starting rc-local.service - /etc/rc.local Compatibility...
Dec 26 16:20:26 J-ThinkPad rc.local[1650]: 2024-12-26 16:20:26 INFO Using /sys/class/power_supply/BAT0
Dec 26 16:20:26 J-ThinkPad rc.local[1650]: 2024-12-26 16:20:26 INFO Setting minimum battery level 75 (before the battery accepts a charge)
Dec 26 16:20:26 J-ThinkPad rc.local[1650]: 2024-12-26 16:20:26 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_start_threshold reports 75 ; success setting value
Dec 26 16:20:26 J-ThinkPad rc.local[1650]: 2024-12-26 16:20:26 INFO Setting maximum battery level 80 (before the battery stops accepting a charge)
Dec 26 16:20:26 J-ThinkPad rc.local[1650]: 2024-12-26 16:20:26 INFO Confirmed /sys/class/power_supply/BAT0/charge_control_end_threshold reports 80 ; success setting value
Dec 26 16:20:26 J-ThinkPad systemd[1]: Started rc-local.service - /etc/rc.local Compatibility.

```

