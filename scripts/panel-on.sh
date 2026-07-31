#!/usr/bin/env bash
# panel-on.sh — Restore the display backlight (undoes panel-off.service)
echo 0 | sudo tee /sys/class/graphics/fb0/blank
echo 0 | sudo tee /sys/class/backlight/intel_backlight/bl_power
