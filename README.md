# mi1201
automatic data acquisition complex for mass-spectrometr mi1201

automatic data acquisition complex for mass-spectrometr mi1201

using

    picoampermetr KEITHLEY 6485 for measuring ion collector signal

    multimetr appa 305 for Hall Sensonr voltage (masses)

    multimetr appa 503 (or 109) for Knudsen cell temperature

linux system config: bind voltmetr appa 305 (503, 109, etc.) to known port in system

$ SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="mass" >> /etc/udev/rules.d/10-local.rules

$ udevadm trigger
