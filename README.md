# My Arch Install steps and scripts

* https://wiki.archlinux.org/title/Installation_guide
  * Download and verify ISO
  * Disable Secure Boot to boot the medium
  * Create boot medium or just use Ventoy

## Install

### Base system
* Boot it up
* Load your preffered keys, eg `loadkeys cz-qwertz`
* Connect to WiFi
  * `iwctl station wlan0 scan`
  * `iwctl station wlan0 connect <SSID>`
  * check internet via ping
* Download `install.sh`
  * -> `curl https://raw.githubusercontent.com/fialakarel/my-arch-install-steps/refs/heads/main/install.sh >install.sh`
* Run `bash install.sh` and follow the install process
* Reboot

### My env
* Boot it up
* * Connect to WiFi
  * `iwctl station wlan0 scan`
  * `iwctl station wlan0 connect <SSID>`
  * check internet via ping
* Download `post-install.sh`
  * -> `curl https://raw.githubusercontent.com/fialakarel/my-arch-install-steps/refs/heads/main/post-install.sh >post-install.sh`
* Run `bash post-install.sh` and follow the install process
* Reboot

### First boot
* Boot it up
* Log into my services and sync data

## Reference
* https://www.mankier.com/4/libinput#Configuration_Details

