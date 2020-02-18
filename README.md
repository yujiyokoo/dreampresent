# dreampresent

Dreamcast Presentation Tool.

This is a presentation tool that runs on Dreamcast.

I developed this for RubyconfTW 2019 and ran my presentation on it.

The presentation content example can be found under romdisk/ directory with images.

If you build this with mruby-dreamcast and run it, you will boot into the presentation.

You can use A or START to move forward, and use B to go back to the previous page.

Hold A + B + Start to quit

The bottom of the screen shows the page progress and time progress (blue dreamcast swirl for page, red mruby for time).

The time is currently hardcoded to 35 minutes.

If you press Right on the D-pad, you move the time forward by 5 minutes, and back by 5 minutes if you press Left.

## Building

To build, you need to pull the docker image 'yujiyokoo/mruby-kos-dc'.

----
> docker pull yujiyokoo/mruby-kos-dc
----

Then you can build the binary with:

----
> docker run -i -t -v $(pwd):/mnt yujiyokoo/mruby-kos-dc bash -c 'cd /mnt && . /opt/toolchains/dc/kos/environ.sh && make'
----

If you have lxdream installed, you can run it with:

----
> lxdream dreampresent.elf
----

