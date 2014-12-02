faust-vst
=========

Albert Gräf <aggraef@gmail.com>, 2014-12-2

This project provides a [VST][1] plugin architecture for the [Faust][2]
programming language. The package contains the Faust architecture,
faustvst.cpp, a collection of sample plugins written in Faust, and a generic
GNU Makefile for compiling the plugins.

NOTE: To compile VST plugins generated with the faustvst architecture, you'll
need the Steinberg SDK version 2.4 or later, which can be obtained here:
<http://www.steinberg.net/en/company/developers.html>. The Makefile assumes
that the SDK files are located at ../vstsdk. If you keep them elsewhere then
you'll have to adjust the SDK variable in the Makefile accordingly.

The present implementation is based on the code of the [faust-lv2][3] plugin
architecture and provides pretty much the same features, such as automatic
controller mappings and voice allocation for polyphonic instrument plugins
(VSTi). The same architecture is used for both effect and instrument
plugins. For the latter, you may define the ``NVOICES`` macro at build time in
the same manner as with the lv2synth.cpp architecture, or you may specify the
maximum number of voices with the ``nvoices`` meta key in the Faust source;
please see the included examples for details. Instrument plugins also support
the MIDI Tuning Standard (MTS) in the same way as with the lv2synth.cpp
architecture, but note that many VST hosts lack support for sending the
corresponding sysex messages to VST plugins right now.

[1]: http://www.steinberg.net/en/company/developers.html
[2]: http://faust.grame.fr/
[3]: https://bitbucket.org/agraef/faust-lv2
