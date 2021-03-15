# Raspberry Pi OS custom image

A simple shell script to customize the latest [Raspberry Pi OS Lite (32-bit)](https://www.raspberrypi.org/software/operating-systems/) image.
With this approach you can only add / modify / delete static files inside the image.
To use native OS commands like apt you have to use QEMU user emulation.

## What things will be customized?

All customizations are centralized in the [customize.sh](https://github.com/escalate/custom-raspberry-pi-os-image/blob/master/customize.sh) script to separate it from the build process.

## When will a new release be created?

A new release of the customized Raspberry Pi OS image is created every Monday at 06:00.

## How to start a build locally?

```
make build
```

## License

MIT
