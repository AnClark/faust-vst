faust-vst
=========

Albert Gräf <aggraef@gmail.com>, 2014-12-2

This project provides a [VST][1] plugin architecture for the [Faust][2]
programming language. The package contains the Faust architecture,
faustvst.cpp, the faust2faustvst helper script which provides a quick way to
compile a plugin, a collection of sample plugins written in Faust, and a
generic GNU Makefile for compiling and installing the plugins.

**NOTE:** To compile VST plugins generated with the faustvst architecture,
you'll need the Steinberg SDK version 2.4 or later, which can be obtained
here: <http://www.steinberg.net/en/company/developers.html>. You need to
register as a developer and accept Steinberg's license agreement, after which
you can download a zip archive with the latest SDK version. There's no
standard location for these files, so you just copy them to any directory on
your system that seems appropriate. As shipped, the Makefile and the
faust2faustvst script assume that you have the SDK files installed in
/usr/local/src/vstsdk; if you keep them elsewhere then you'll have to adjust
the SDK variable in these files accordingly.

Installation
------------

Make sure that you have the VST SDK installed in the appropriate location,
then run `make` and `make install`. The latter will install the compiled
plugins under /usr/local/lib/vst by default. There's also a `make
install-faust` target to install the faust2faustvst script into /usr/local/bin
and the faustvst.cpp architecture into /usr/local/lib/faust, respectively.

You can adjust the installation prefix with the `prefix` make variable, and
package maintainers can specify a staging directory with the `DESTDIR`
variable as usual.

Usage
-----

The present implementation is based on the code of the [faust-lv2][3] plugin
architecture and provides pretty much the same features, such as automatic
controller mappings and voice allocation for polyphonic instrument plugins
(VSTi). The same architecture is used for both effect and instrument
plugins. For the latter, you may define the `NVOICES` macro at build time in
the same manner as with the lv2synth.cpp architecture, or you may specify the
maximum number of voices with the `nvoices` meta key in the Faust source;
please see the included examples for details. Instrument plugins also support
the MIDI Tuning Standard (MTS) in the same way as with the lv2synth.cpp
architecture, but note that many VST hosts lack support for sending the
corresponding sysex messages to VST plugins right now.

To compile your own plugins, you can use the provided faustvst.cpp
architecture with the Faust compiler like this: `faust -a faustvst.cpp`. You
then need to compile the resulting C++ source and link it against some SDK
modules to obtain a working plugin. To facilitate this process, you can either
use the provided Makefile or the faust2faustvst helper script. For instance,
`faust2faustvst amp.dsp` will compile `amp.dsp` using the Faust compiler and
then invoke the C++ compiler on the resulting C++ code to create a working
plugin. All the necessary compiler and linker options are provided
automatically.

To compile an instrument plugin, you can either specify the maximum polyphony
with the `-nvoices` option of the faust2faustvst script or add a definition
like the following to the beginning of your Faust source:

    nvoices "16";

If both are specified then the command line option takes precedence. Using
`-nvoices 0` creates an ordinary effect plugin without MIDI note processing.

Please check organ.dsp for a simple example of an instrument plugin. The rules
for creating the voice controls `freq`, `gain` and `gate` are the same as for
the lv2synth.cpp architecture.

[1]: http://www.steinberg.net/en/company/developers.html
[2]: http://faust.grame.fr/
[3]: https://bitbucket.org/agraef/faust-lv2
