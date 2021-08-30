FROM raspberryos-img

ADD qemu-arm-static /usr/bin/qemu-arm-static

ENTRYPOINT /bin/bash
