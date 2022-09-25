
# Dreampresent: The Dreamcast Presentation Tool

This is a presentation tool that runs on **Sega Dreamcast**.  It was written in **Ruby** (instead of **C/C++** which is usually the case for Sega Dreamcast programs!).

I developed this for **RubyConf TW 2019** and ran my presentation on it. Later it was updated for **RubyConf AU 2020** as you may see below.

[![#Developing your Dreamcast games with mruby - Yuji Yokoo (RubyConf AU 2020)](https://img.youtube.com/vi/ni-1x5Esa_o/0.jpg)](https://www.youtube.com/watch?v=ni-1x5Esa_o)

## Usage

You can use `A` or `START` to move forward, and use `B` to go back to the previous page.

Hold `A + B + Start` to quit.

The bottom of the screen shows the page progress and time progress (blue dreamcast swirl for page, red mruby for time).

The time is currently hardcoded to `35` minutes.

If you press `Right` on the D-pad, you move the time forward by 5 minutes, and back by 5 minutes if you press `Left`.

## Building

**Dreampresent** uses [KallistiOS](http://gamedev.allusion.net/softprj/kos/) (KOS) and [mruby](https://mruby.org/) as dependencies. For building this program you have two options: 
* Using a working KallistiOS setup;
* Use the provided Docker image below.

The presentation content can be found under `romdisk/` directory, it's embedded when building the program.

**Note:** You will need the `libpng` KallistiOS Ports installed for building this program.

### Using your KallistiOS environment

If you have a working [KallistiOS](http://gamedev.allusion.net/softprj/kos/) environment, you will have to install the `rake` and `bison` packages (e.g. using `apt`, `brew` or `pacman`). If you are using [DreamSDK](https://dreamsdk.org), you will have to install the [RubyInstaller](https://rubyinstaller.org/) package separately, in that case, `rake` should be available in the `PATH` environment variable.

Install  `mruby`:

	cd /opt
	git clone https://github.com/mruby/mruby.git
	cd /opt/mruby
	make MRUBY_CONFIG=dreamcast_shelf

These commands will produces all the necessary files for using **mruby** on Sega Dreamcast. After that, just navigate to the `dreampresent` directory then enter `make`. This will produces the `dreampresent.elf` file.

**Note:** You may consult [this page](https://dreamcast.wiki/Using_Ruby_for_Sega_Dreamcast_development) for reference.

### Using Docker image

To build, you need to pull the Docker image `yujiyokoo/mruby-kos-dc`.

	docker pull yujiyokoo/mruby-kos-dc

Then you can build the binary with:

	docker run -i -t -v $(pwd):/mnt yujiyokoo/mruby-kos-dc bash -c 'cd /mnt && . /opt/toolchains/dc/kos/environ.sh && make'

## Executing

### Lxdream

If you have the **Lxdream** Sega Dreamcast emulator installed, you can run it with:

	lxdream dreampresent.elf

### Making a bootable image

If you want to try this software in your real Dreamcast and/or in an emulator, you may create a **Padus DiscJuggler** (`cdi`) image. For example, if you are using [DreamSDK](https://dreamsdk.org), you may do the following:

	make dist
	makedisc dreampresent.cdi cd_root

This will produces the `dreampresent.cdi` image file that you may burn onto a CD-R or use in a Dreamcast Emulator.

### Using dcload/dc-tool (part of KallistiOS)

If you have a [Coders Cable](https://dreamcast.wiki/Coder%27s_cable) or a [Broadband Adapter](https://dreamcast.wiki/Broadband_adapter) (BBA) / [LAN Adapter](https://dreamcast.wiki/LAN_adapter), you could also the `dcload` program (part of **KallistiOS**) to load it directly on the Sega Dreamcast. It should load as a normal Sega Dreamcast program.

To do that, you may enter the following:

	make run

This will execute `dc-tool` using the `dreampresent.elf` binary file as target.

