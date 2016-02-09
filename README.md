faust-vst
=========

Albert Gräf <aggraef@gmail.com>, 2014-12-04

This project provides a [VST][1] plugin architecture for the [Faust][2]
programming language. The package contains the Faust architecture,
faustvst.cpp, the faust2faustvst helper script which provides a quick way to
compile a plugin, a collection of sample plugins written in Faust, and a
generic GNU Makefile for compiling and installing the plugins.

Please note that the faustvst.cpp architecture provided here is different from
Yan Michalevsky's vst.cpp architecture included in the Faust distribution.
faust-vst is a separate development based on the [faust-lv2][3] project, and
as such it offers the same set of features as faust-lv2. Except for the
portamento feature in the vst.cpp architecture, which isn't supported in
faust-vst right now, the capabilities provided by our architecture are a
strict superset of those of the vst.cpp architecture. In particular, faust-vst
uses a voice assignment algorithm which properly deals with multi-channel MIDI
data, and it provides automatic MIDI controller assignments and MTS tuning
capabilities. Faust sources that have been developed for faust-lv2 should just
take a recompile to make them work in exactly the same way in any VST host.

At present, faust-vst has been tested and is known to work on recent Linux and
Mac OS X versions. Support for Windows should be a piece of cake, though, and
will hopefully be added in the near future. To improve cross-platform
compatibility, faustvst.cpp doesn't include any GUI code; it completely relies
on the VST host for rendering control GUIs. This keeps things simple, but it
also means that if you want prettier GUIs then you'll have to code them
yourself. Also, support for Faust's external OSC and HTTPD control facilities
is still on the TODO list at this time.

The architecture has been given some fairly thorough testing using various
open-source and commercial DAWs on both Linux and Mac OS X, among them Ardour,
Bitwig, Qtractor, Reaper and Tracktion. It appears to work fine with each of
these, but if you notice any bugs then please head over to
<https://bitbucket.org/agraef/faust-vst> and report them there.

Copying
-------

Like most other Faust architectures, faust-vst is licensed under the LGPL,
please check the included COPYING and COPYING.LESSER files for details. This
implies, in particular, that the architecture can be used in proprietary
software only if you also provide a means which lets users build your plugin
with a suitably modified version of the architecture. (The only practical way
to do this right now is to provide the Faust source of your plugin. If this
doesn't suit you then feel free to contact me for obtaining a commercial
license, or have a look at Yan Michalevsky's vst.cpp architecture which is
licensed under a more liberal BSD-style license.)

Note that in order to create a working VST plugin using the faustvst.cpp
architecture, you'll also need Steinberg's VST SDK (see below). This is
proprietary software, so if you publish a plugin that is created using this
architecture then you'll also have to comply with Steinberg's license terms.
Please check the documentation accompanying the VST SDK distribution for
details.

Prerequisites
-------------

To compile plugins with the vstsdk.cpp architecture, you need to have Faust,
GNU make and a suitable C++ compiler installed. The Makefile uses whatever the
CXX variable indicates. The faust2faustvst script uses gcc by default, but you
can change this by editing the script file. Both gcc and clang should work out
of the box, other C++ compilers may need some twiddling with the compiler
options in the Makefile and the faust2faustvst script.

You'll also need the Steinberg SDK version 2.4 or later. A zip archive with
the latest SDK version can be found here:
<http://www.steinberg.net/en/company/developers.html>. There's no standard
location for these files, so you just copy them to any directory on your
system that seems appropriate. For instance:

    unzip vstsdk360_22_11_2013_build_100.zip
    sudo mkdir -p /usr/local/src
    sudo mv 'VST3 SDK' /usr/local/src/vstsdk

The name of the zip file and the package directory will of course vary with
the version of the SDK you downloaded; at the time of this writing, VST SDK
3.6.0 is the current version.

The faust-vst Makefile will look for the SDK files in some common locations
(including the /usr/local/src/vstsdk path suggested above) and configure
itself and the faust2faustvst script accordingly at build time. If it gets
this wrong or cannot find the files then you can also set the location
explicitly when invoking make:

    make SDK=/path/to/the/SDK

You should specify an absolute path there; the Makefile will most likely work
with a relative path as well, but then you'll always have to run
faust2faustvst from the same directory.

Installation
------------

Make sure that you have the VST SDK installed in an appropriate location, as
discussed above, then run `make` and `make install`. The latter will install
the compiled plugins under /usr/local/lib/vst by default; you need root access
or administrator privileges to be able to do that. Instead, you can also
install the plugins in your personal VST plugin folder (e.g., ~/.vst on
Linux):

    make install vstlibdir=~/.vst

Or you might just copy the compiled plugins (.so files on Linux) manually to
whatever directory you want to use:

    cp examples/*.so ~/.vst

Note that in the case of Mac OS X, the plugins are actually bundles (i.e.,
directories) with the `.vst` extension which need to be copied using `-R`:

    cp -R examples/*.vst ~/Library/Audio/Plug-Ins/VST

But usually running just `make install` with the appropriate `vstlibdir`
should do the trick on any supported platform.

Please note that in any case this step is optional. The included plugins are
just examples which you can use to test that everything compiles ok and to
check for compatibility of the plugins with your VST host. You may want to
skip this step if you're only interested in compiling your own plugins.

For compiling your own Faust sources, only the faustvst.cpp architecture and
the faust2faustvst helper script are needed. As of 2016-02-09, these are now
also included in the latest revisions of the Faust compiler, so if you
installed Faust from the latest git sources after that date, chances are that
you already have it.

If you're still running an older Faust version shipping without faust-vst then
the `make install-faust` target of this package provides you with a quick way
to add the architecture and the helper script to your existing Faust
installation. It copies these items to the appropriate directories; the
faust2faustvst script goes into /usr/local/bin and the faustvst.cpp
architecture into /usr/local/lib/faust by default.

Both `make install` and `make install-faust` let you adjust the installation
prefix with the `prefix` make variable, and package maintainers can specify a
staging directory with the `DESTDIR` variable as usual. There's a bunch of
other variables which let you set various compilation options and installation
paths; please check the Makefile for details.

Also note that on Mac OS X, the Makefile and the faust2faustvst script will
create universal (32 and 64 bit Intel) binaries by default, which should be
usable with both 32 and 64 bit VST hosts. You can change this by adjusting the
`ARCH` variable in the Makefile and the script accordingly. E.g., setting
`ARCH` to something like `"-arch i386"` will create 32 bit Intel binaries
only, while leaving `ARCH` empty creates binaries for the default architecture
of your system (usually 64 bit these days). While some 64 bit hosts such as
Reaper will work just fine with 32 bit VST plugins, others such as Tracktion
may require 64 bit plugins for the 64 bit version of the program. Going with
the fat binaries should have you covered in either case.

Usage
-----

As already mentioned, the present implementation is based on the code of the
[faust-lv2][3] plugin architecture and provides pretty much the same set of
features, in particular: automatic controller mappings (observing the
`midi:ctrl` attributes in the Faust source), multi-channel voice assignment
for polyphonic instrument plugins (VSTi), as well as support for pitch bend
range and master tuning (RPN) messages and MIDI Tuning Standard (MTS)
messages. The `unit` attribute is also supported, but note that none of the
LV2-specific attributes of the faust-lv2 architecture are implemented right
now.

To compile your own plugins, you can use the provided faustvst.cpp
architecture with the Faust compiler like this: `faust -a faustvst.cpp
mydsp.dsp`. You then need to compile the resulting C++ source and link it
against some SDK modules to obtain a working plugin. The necessary steps are
all rather straightforward, but vary with the target platform (e.g., on OS X
you need to create a proper Mach-O bundle) and require some knowledge about
compiler and linker options as well as some VST-specific requirements.

To facilitate this process, we recommend using either the provided Makefile or
the faust2faustvst helper script. The Makefile can be used either as a
starting point for your own Faust-VST plugin projects, or you can just drop
your Faust sources into the examples directory to have them built along with
the other examples.

The faust2faustvst script is invoked as follows:

    faust2faustvst amp.dsp

This will compile `amp.dsp` using the Faust compiler and then invoke the C++
compiler on the resulting C++ code to create a working plugin. All the
necessary compiler and linker options are provided automatically, and on OS X
the script also takes care of creating a proper VST bundle.

In contrast to faust-lv2, the same architecture is used for both effect (VST)
and instrument (VSTi) plugins. For the latter, you may define the `NVOICES`
macro at build time in the same manner as with the lv2synth.cpp architecture.
Moreover, it is also possible to specify the maximum number of voices with the
`nvoices` meta key in the Faust source.

Please check examples/organ.dsp in the distributed sources for a simple
example of an instrument plugin. The rules for creating the voice controls
`freq`, `gain` and `gate` are the same as for the lv2synth.cpp architecture.
To compile an instrument plugin with the faust2faustvst script, you can
specify the maximum polyphony with the `-nvoices` option, e.g.:

    faust2faustvst -nvoices 16 organ.dsp

Or you may add a definition like the following to the beginning of your Faust
source:

    nvoices "16";

If both are specified then the command line option takes precedence. Using
`-nvoices 0` (or `nvoices "0";` in the Faust source) creates an ordinary
effect plugin without MIDI note processing. This is also the default if none
of these options are specified.

MTS Support
-----------

As with faust-lv2, VST instruments created with the faustvst.cpp architecture
can be retuned using sysex messages in MTS (MIDI Tuning Standard) format. At
present, the supported formats are 1- or 2-byte octave-based tunings, please
check the faust-lv2 documentation for details on this. We also offer a program
which generates MTS messages in these formats from human-readable scale
definitions in the Scala format and stores them as Sysex (.syx) or MIDI (.mid)
files. You can find this program at <https://bitbucket.org/agraef/sclsyx>.

To use this, your VST host needs to be able to receive and/or store sysex
messages and pass them on to VSTi plugins. Unfortunately, not all VST hosts
implement this feature at this time. As a remedy, the faustvst.cpp
architecture also provides an additional `tuning` control which allows you to
choose a tuning from a collection of MTS sysex files determined at load
time. (This feature can also be disabled with a corresponding compilation
option, please check the Makefile for details.) You then just need to drop
some MTS sysex (.syx) files into the ~/.faust/tuning folder. If this folder is
present and contains some MTS sysex files in the right format, then the
`tuning` control becomes available on all faust-vst instrument plugins which
have been compiled with this option. The control usually takes the form of a
slider which shows the current value (both the basename of the tuning file and
the corresponding numeric value). The tunings are numbered in alphabetic order
starting at 1; a slider value of 0 denotes the default tuning (equal
temperament). Changing the slider value in the control GUI provided by your
VST host adjusts the tuning accordingly.

This controller-based method for changing the tuning will of course become
rather unwieldy if you need to work with a large number of different tunings.
On the other hand, it also offers the advantage that the tuning becomes an
automatable parameter which can be recorded and played back by hosts which
provide control automation (your favorite DAW probably does). Note that the
amount of data in the octave-based tunings is rather small and the data is
stored in main memory at load time, so that changing tunings in real-time is
not an expensive operation.

**NOTE:** Instead of ~/.faust you can also name a different "home" folder by
setting the FAUST_HOME environment variable accordingly. In addition, on Mac
OS X the ~/Library/Faust/Tuning folder will also be searched for tunings if
~/.faust/tuning doesn't exist or contains no valid sysex files.

[1]: http://www.steinberg.net/en/company/developers.html
[2]: http://faust.grame.fr/
[3]: https://bitbucket.org/agraef/faust-lv2
