# How to compile Raspberry OS from the RaspiFoundation into a docker image
1. Download Raspberry OS
2. `fdisk -l 2021-05-07-raspios-buster-armhf-lite.img`
3. Take start position of the second partition, and multiply it by the sector size (512). `532480x512=272629760`
4. `sudo mount -o loop,offset=272629760,ro 2021-05-07-raspios-buster-armhf-lite.img /mnt`
5. `sudo tar -C /mnt -c . | docker import - raspberryos-img`
6. `sudo docker build --no-cache -t darkenvy/raspberryos:TAGNAME .`
7. `docker push darkenvy/raspberryos:TAGNAME`
8. `docker image rm raspberryos-img`


# How to run ARM docker container on x86_64
The ability to run a ARM container on x64 is not determined by how the docker image is constructed, but instead of how the host-OS is set up. If the host-OS has the ARM header registered in `/proc/sys/fs/binfmt_misc`, then whenever the kernel comes across a ARM binary, it will search for qemu located at /usr/bin/qemu-arm-static. 

If the kernel comes across a ARM binary when operating inside a docker container, then it will look for qemu-arm-static from `/usr/bin/qemu-arm-static` relative to the docker container. Therefore, each docker container must contain the qemu-arm-static binary.

### How to register the host-OS to utilize qemu (inside and outside of docker)
1. Verify binfmt_misc is mounted
  a. `grep binfmt /proc/mounts`
  b. `cat /proc/sys/fs/binfmt_mist/status`
2. Mount binfmt if needed. `mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc`
  a. Note: Modern linux distros will have binfmt already enabled.
3. Enable if needed. `echo 1 > /proc/sys/fs/binfmt_misc/status`
4. Register the arm header info to binfmt: `sudo sh -c "echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > /proc/sys/fs/binfmt_misc/register"`
5. Done! 
  a. This container is built with qemu injected already. For other containers, all you have to do is volume mount pointing to qemu. `docker run -it -v $(pwd)/qemu-arm-static:/usr/bin/qemu-arm-static darkenvy/raspberryos /bin/bash`
  b. Note: If you dont have qemu-arm-static at `/usr/bin/qemu-arm-static` on the host, then the host will not execute ARM. This is fine and totally Optional.
