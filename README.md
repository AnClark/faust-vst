faust-vst
=========

Albert Gräf <aggraef@gmail.com>, 2014-12-2

This project provides a [VST][1] plugin architecture for the [Faust][2]
programming language. The package contains the Faust architecture,
faustvst.cpp, the faust2faustvst helper script which provides a quick way to
compile a plugin, a collection of sample plugins written in Faust, and a
generic GNU Makefile for compiling and installing the plugins.

Please note that the faustvst.cpp architecture provided here is different from
Yan Michalevsky's vst.cpp architecture included in the latest Faust versions.
faust-vst is a separate development based on the [faust-lv2][3] project, and
as such it offers the same set of features as faust-lv2. In particular,
faust-vst uses a voice allocation algorithm which properly deals with
multi-channel MIDI data, and it provides automatic MIDI controller assignments
and MTS tuning capabilities. Faust sources that have been developed for
faust-lv2 should just take a recompile to make them work in exactly the same
way in any VST host (the MTS support requires a VST host which can send sysex
data to plugins, however).

At present, faust-vst has been tested and is known to work on Linux. Support
for Mac OS X and Windows should be a piece of cake, though, and will hopefully
be available in the near future.

Prerequisites
-------------

To compile plugins with the vstsdk.cpp architecture, you need to have Faust,
GNU make and a suitable C++ compiler installed. The Makefile uses whatever the
CXX variable indicates. The faust2faustvst script uses gcc by default, but you
can change this by editing the script file. Both gcc and clang should work out
of the box, other C++ compilers may need some twiddling with the compiler
options in the Makefile and the faust2faustvst script.

You'll also need the Steinberg SDK version 2.4 or later. Unfortunately, the
VST SDK isn't redistributable, so you must register as a developer on the
Steinberg website and download it yourself. At the time of this writing, the
SDK is available at <http://www.steinberg.net/en/company/developers.html>.
After completing the registration and accepting the license term, you can
download a zip archive with the latest SDK version there. There's no standard
location for these files, so you just copy them to any directory on your
system that seems appropriate. For instance:

    unzip vstsdk360_22_11_2013_build_100.zip
    mv 'VST3 SDK' vstsdk
    sudo mv vstsdk /usr/local/src

The name of the zip file and the package directory will of course vary with
the version of the SDK you downloaded; at the time of this writing, VST SDK
3.6.0 is the current version.

The distributed Makefile and the faust2faustvst script assume that you have
the SDK files installed in /usr/local/src/vstsdk, as indicated above. If you
keep them elsewhere then you'll have to adjust the SDK variable in these files
accordingly.

Installation
------------

Make sure that you have the VST SDK installed in the appropriate location,
then run `make` and `make install`. The latter will install the compiled
plugins under /usr/local/lib/vst by default; you need root access or
administrator privileges to be able to do that. Instead, you can also install
the plugins in your personal VST plugin folder (e.g., ~/.vst on Linux):

    make install vstlibdir=~/.vst

Or you might just copy the compiled plugins (.so files on Linux) manually to
whatever directory you want to use:

    cp examples/*.so ~/.vst

Please note that this step is optional. The included plugins are just examples
which you can use to test that everything compiles ok and to check for
compatibility of the plugins with your VST host. You may want to skip this
step if you're only interested in compiling your own plugins.

For compiling your own Faust sources, only the faustvst.cpp architecture and
the faust2faustvst helper script are needed. There's a `make install-faust`
target which installs these items in the appropriate directories; the
faust2faustvst script goes into /usr/local/bin and the faustvst.cpp
architecture into /usr/local/lib/faust. As faust-vst isn't included in the
Faust distribution yet, this make target provides you with an easy way to add
the architecture and the helper script to your existing Faust installation.

Both `make install` and `make install-faust` let you adjust the installation
prefix with the `prefix` make variable, and package maintainers can specify a
staging directory with the `DESTDIR` variable as usual.

Usage
-----

As already mentioned, the present implementation is based on the code of the
[faust-lv2][3] plugin architecture and provides pretty much the same, fairly
comprehensive set of features, in particular: automatic controller mappings
(observing the `midi:ctrl` attributes in the Faust source), multi-channel
voice allocation for polyphonic instrument plugins (VSTi), as well as support
for pitch bend range and master tuning (RPN) messages and MIDI Tuning Standard
(sysex) messages. The `unit` attribute is also supported, but note that none
of the LV2-specific attributes of the faust-lv2 architecture are implemented
right now.

To compile your own plugins, you can use the provided faustvst.cpp
architecture with the Faust compiler like this: `faust -a faustvst.cpp
mydsp.dsp`. You then need to compile the resulting C++ source and link it
against some SDK modules to obtain a working plugin. To facilitate this
process, we recommend using either the provided Makefile or the faust2faustvst
helper script. For instance, `faust2faustvst amp.dsp` will compile `amp.dsp`
using the Faust compiler and then invoke the C++ compiler on the resulting C++
code to create a working plugin. All the necessary compiler and linker options
are provided automatically.

In contrast to faust-lv2, the same architecture is used for both effect (VST)
and instrument (VSTi) plugins. For the latter, you may define the `NVOICES`
macro at build time in the same manner as with the lv2synth.cpp architecture.
Moreover, it is also possible to specify the maximum number of voices with the
`nvoices` meta key in the Faust source.

Please check examples/organ.dsp in the distributed sources for a simple
example of an instrument plugin. The rules for creating the voice controls
`freq`, `gain` and `gate` are the same as for the lv2synth.cpp architecture.
To compile an instrument plugin with the faust2faustvst script, you can either
specify the maximum polyphony with the `-nvoices` option, e.g.:
`faust2faustvst -nvoices 16 organ.dsp`. Or you may add a definition like the
following to the beginning of your Faust source:

    nvoices "16";

If both are specified then the command line option takes precedence. Using
`-nvoices 0` (or `nvoices "0";` in the Faust source) creates an ordinary
effect plugin without MIDI note processing. This is also the default if none
of these options are specified.

[1]: http://www.steinberg.net/en/company/developers.html
[2]: http://faust.grame.fr/
[3]: https://bitbucket.org/agraef/faust-lv2
