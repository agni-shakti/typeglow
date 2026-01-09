# typeglow

Reactive keyboard backlight daemon for Samsung Galaxy Book laptops on Linux.

## What it does
- Instantly sets keyboard backlight to maximum when a key is pressed
- Fades back to the previous brightness after typing stops
- Handles fast typing correctly (no brightness drift)
- Runs as a systemd service

## Requirements
- Linux
- Samsung Galaxy Book (tested)
- evtest
- systemd
- root access

## Installation

sudo cp typeglow.sh /usr/local/bin/typeglow
sudo chmod +x /usr/local/bin/typeglow

## Install systemd service

sudo cp systemd/typeglow.service /etc/systemd/system/typeglow.service
sudo systemctl daemon-reload
sudo systemctl enable typeglow.service
sudo systemctl start typeglow.service

### Install dependencies
```bash
sudo apt install evtest

## Configuration

Edit the variables at the top of typeglow.sh:

DEVICE

MAX

STEP_DELAY

TRIGGER_DELAY

## Warning

This daemon reads raw input events and must run as root.
Only use on systems you trust.
