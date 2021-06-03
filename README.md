# Raspberry Pi OS custom image

[![Customize Raspberry Pi OS image](https://github.com/escalate/raspberry-pi-os-custom-image/actions/workflows/customize-raspberry-pi-os-image.yml/badge.svg?event=push)](https://github.com/escalate/raspberry-pi-os-custom-image/actions/workflows/customize-raspberry-pi-os-image.yml)

A simple shell script to customize the latest [Raspberry Pi OS Lite (32-bit / 64-bit)](https://www.raspberrypi.org/software/operating-systems/) image.
With this approach you can only add / modify / delete static files inside the image.
To use native OS commands like apt you have to use QEMU user emulation.

## What things will be customized?

All customizations are centralized in the [customize.sh](https://github.com/escalate/custom-raspberry-pi-os-image/blob/master/customize.sh) script to separate it from the build process.

## How to start the build process locally?
32-bit version:
```
make build32
```
64-bit version:

```
make build64
```

## License

MIT
