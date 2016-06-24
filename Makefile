# This is a GNU Makefile.

# Package name and version:
dist = faust-vst-$(version)
version = 1.0

# Installation prefix and default installation dirs. NOTE: vstlibdir is used
# to install the plugins, bindir and faustlibdir for the Faust-related tools
# and architectures. You can also set these individually if needed.
prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
vstlibdir = $(libdir)/vst
faustlibdir = $(libdir)/faust

# Try to guess the Faust installation prefix.
faustprefix = $(patsubst %/bin/faust,%,$(shell which faust 2>/dev/null))
ifeq ($(strip $(faustprefix)),)
# Fall back to /usr/local.
faustprefix = /usr/local
endif
incdir = $(faustprefix)/include
faustincdir = $(incdir)/faust

# Set this variable to build the plugin GUIs. This option requires Qt4 or Qt5
# (Qt5 is recommended).
gui = 0

# qmake setup (for GUI compilation). We prefer Qt5 if it is available. You may
# have to set this explicitly if the qmake executable isn't found or you want
# to choose a different Qt version.
qmake=$(shell which qmake-qt5 || which /opt/local/libexec/qt5/bin/qmake || which qmake-qt4 || which /opt/local/libexec/qt4/bin/qmake || echo qmake)

# Determine the Qt version so that we can pick the needed compilation options.
qtversion = $(shell $(qmake) -v 2>/dev/null | tail -1 | sed 's/.*Qt version \([0-9]\).*/\1/')

ifeq ($(qtversion),5)
QTEXTRA = x11extras
endif

# Check for some common locations of the SDK files. This falls back to
# /usr/local/src/vstsdk if none of these are found. In that case, or if make
# picks the wrong location, you can also set the SDK variable explicitly.
sdkpaths = /usr/local/include /usr/local/src /usr/include /usr/src
sdkpat = vst* VST*
#SDK = /usr/local/src/vstsdk
SDK = $(firstword $(wildcard $(foreach path,$(sdkpaths),$(addprefix $(path)/,$(sdkpat)))) /usr/src/vstsdk)
# Steinberg's distribution zip has the SDK source files in the
# public.sdk/source/vst2.x subdirectory, while some Linux packages (e.g.,
# steinberg-vst on the AUR) keep them directly under $(SDK).
#SDKSRC = $(SDK)/public.sdk/source/vst2.x
SDKSRC = $(firstword $(patsubst %/,%,$(dir $(wildcard $(addsuffix vstplugmain.cpp,$(SDK)/ $(SDK)/public.sdk/source/vst2.x/)))) $(SDK)/public.sdk/source/vst2.x)

# Here are a few conditional compilation directives which you can set.
# Disable Faust metadata.
#DEFINES += -DFAUST_META=0
# Disable MIDI controller processing.
#DEFINES += -DFAUST_MIDICC=0
# Disable the tuning control (synth only).
#DEFINES += -DFAUST_MTS=0
# Disable polyphony/tuning controls on GUI.
#DEFINES += -DVOICE_CTRLS=0
# Number of voices (synth: polyphony).
#DEFINES += -DNVOICES=16
# Debug recognized MIDI controller metadata.
#DEFINES += -DDEBUG_META=1
# Debug incoming MIDI messages.
#DEFINES += -DDEBUG_MIDI=1
# Debug MIDI note messages (synth).
#DEFINES += -DDEBUG_NOTES=1
# Debug MIDI controller messages.
#DEFINES += -DDEBUG_MIDICC=1
# Debug RPN messages (synth: pitch bend range, master tuning).
#DEFINES += -DDEBUG_RPN=1
# Debug MTS messages (synth: octave/scale tuning).
#DEFINES += -DDEBUG_MTS=1

# This is set automatically according to the gui option.
ifneq ($(gui),0)
DEFINES += -DFAUST_UI=1
endif

# GUI configuration. Adjust as needed/wanted.
# Uncomment this to get OSC and/or HTTP support in the plugin GUIs.
#UI_DEFINES += -DOSCCTRL -DHTTPCTRL
# Uncomment this to also get the QR code popup for HTTP.
#UI_DEFINES += -DQRCODECTRL
# Uncomment this to set a special style sheet. This must be the basename of
# one of the style sheets available in $(faustincdir)/gui/Styles.
#STYLE = Grey

# Add the libraries needed for the UI options above.
ifneq "$(findstring -DOSCCTRL,$(UI_DEFINES))" ""
UI_LIBS += -lOSCFaust
endif
ifneq "$(findstring -DHTTPCTRL,$(UI_DEFINES))" ""
UI_LIBS += -lHTTPDFaust -lmicrohttpd
endif
ifneq "$(findstring -DQRCODECTRL,$(UI_DEFINES))" ""
UI_LIBS += -lqrencode
endif

ifneq "$(STYLE)" ""
UI_DEFINES += -DSTYLE=$(STYLE)
RESOURCES = $(faustincdir)/gui/Styles/$(STYLE).qrc
endif

# Uncomment this to keep the Qt GUI projects after compilation.
#KEEP = true

# Additional Faust flags.
# Uncomment the following to have Faust substitute the proper class name into
# the C++ code. Be warned, however, that this requires that the basename of
# the dsp file is a valid C identifier, which isn't guaranteed.
#FAUST_FLAGS += -cn $(@:examples/%.cpp=%)

# Default compilation flags.
CXXFLAGS = -O3
# Use this for debugging code instead.
#CXXFLAGS = -g -O2

# Shared library suffix and compiler option to create a shared library.
DLL = .so
shared = -shared

# Try to guess the host system type and figure out platform specifics.
host = $(shell ./config.guess)
ifneq "$(findstring -mingw,$(host))" ""
# Windows (untested)
EXE = .exe
DLL = .dll
endif
ifneq "$(findstring -darwin,$(host))" ""
# OSX
DLL = .vst
# Build fat binaries which will work with both 32 and 64 bit hosts.
ARCH = -arch i386 -arch x86_64
EXTRA_CFLAGS += $(ARCH)
shared = -bundle $(ARCH)
# MacPorts compatibility
EXTRA_CFLAGS += -I/opt/local/include
endif
ifneq "$(findstring x86_64-,$(host))" ""
# 64 bit, needs -fPIC flag
EXTRA_CFLAGS += -fPIC
endif
ifneq "$(findstring x86,$(host))" ""
# architecture-specific options for x86 and x86_64
EXTRA_CFLAGS += -msse -ffast-math
endif

# DSP sources and derived files.
dspsource = $(sort $(wildcard */*.dsp))
cppsource = $(patsubst %.dsp,%.cpp,$(dspsource))
objects = $(patsubst %.dsp,%.o,$(dspsource))
plugins = $(patsubst %.dsp,%$(DLL),$(dspsource))
# These timestamp files are only created when generating OS X bundles.
stamps = $(patsubst %.dsp,%.stamp,$(dspsource))

# Extra objects with VST-specific code needed to build the plugins.
main = vstplugmain
afx = audioeffect
afxx = audioeffectx
extra_objects = $(addsuffix .o, $(main) $(afx) $(afxx))

# Architecture name.
arch = faustvst

EXTRA_CFLAGS += -I$(SDK) -I$(SDKSRC) -Iexamples -D__cdecl= $(DEFINES)

.PHONY: all clean install uninstall install-faust uninstall-faust dist distcheck

all: $(plugins)

# Generic build rules.

%.cpp: %.dsp
	faust -a $(arch).cpp -I examples $(FAUST_FLAGS) $< -o $@

$(main).o: $(SDKSRC)/$(main).cpp
	$(CXX) $(CXXFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<

$(afx).o: $(SDKSRC)/$(afx).cpp
	$(CXX) $(CXXFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<

$(afxx).o: $(SDKSRC)/$(afxx).cpp
	$(CXX) $(CXXFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<

%.o: %.cpp $(arch).cpp
	$(CXX) $(CXXFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<

ifndef KEEP
KEEP = false
endif

ifeq ($(gui),0)
ifeq "$(DLL)" ".vst"
# This rule builds an OS X bundle. Since the target %.vst is a directory here,
# we have to go to some lengths to prevent make from rebuilding the target
# each time.
.PRECIOUS: %.stamp
%.vst: %.stamp
	@echo made $@ >/dev/null
%.stamp: %.o $(extra_objects)
	mkdir -p $(@:.stamp=.vst)/Contents/MacOS
	printf '%s' 'BNDL????' > $(@:.stamp=.vst)/Contents/PkgInfo
	sed -e 's?@name@?$(notdir $(@:.stamp=))?g;s?@version@?1.0.0?g' < Info.plist.in > $(@:.stamp=.vst)/Contents/Info.plist
	$(CXX) $(shared) $^ -o $(@:.stamp=.vst)/Contents/MacOS/$(notdir $(@:.stamp=))
	touch $@
else
%$(DLL): %.o $(extra_objects)
	$(CXX) $(shared) $^ -o $@
endif
else
# We need to invoke qmake here. This needs Qt4 or Qt5.
# XXXTODO: OSX support
ifneq "$(DLL)" ".vst"
%$(DLL): %.cpp $(extra_objects)
	+(tmpdir=$(dir $@)$(notdir $(<:%.cpp=%.src)); rm -rf $$tmpdir; mkdir -p $$tmpdir; cp $< $$tmpdir; cd $$tmpdir; $(qmake) -project -t lib -o "$(notdir $(<:%.cpp=%.pro))" "CONFIG += gui plugin no_plugin_name_prefix warn_off" "QT += widgets printsupport network $(QTEXTRA)" "INCLUDEPATH+=$(CURDIR)" "INCLUDEPATH+=.." "INCLUDEPATH+=$(faustincdir)" "QMAKE_CXXFLAGS=$(CXXFLAGS) $(EXTRA_CFLAGS) $(UI_DEFINES)" "LIBS+=$(UI_LIBS)" "LIBS+=$(addprefix $(CURDIR)/, $(extra_objects))" "HEADERS+=$(CURDIR)/faustvstqt.h" "HEADERS+=$(faustincdir)/gui/faustqt.h" "RESOURCES+=$(RESOURCES)"; $(qmake) *.pro && make && cp $(notdir $@) .. && cd $(CURDIR) && ($(KEEP) || rm -rf $$tmpdir))
endif
endif

# Clean.

clean:
	rm -Rf $(dspsource:.dsp=.src) $(cppsource) $(stamps) $(objects) $(extra_objects) $(plugins)

# Install.

install: $(plugins)
	test -d $(DESTDIR)$(vstlibdir) || mkdir -p $(DESTDIR)$(vstlibdir)
	cp -Rf $(plugins) $(DESTDIR)$(vstlibdir)

uninstall:
	rm -Rf $(addprefix $(DESTDIR)$(vstlibdir)/, $(notdir $(plugins)))

# Use this to add the Faust architectures and scripts included in this package
# to an existing Faust installation.

install-faust:
	test -d $(DESTDIR)$(bindir) || mkdir -p $(DESTDIR)$(bindir)
	cp faust2faustvst $(DESTDIR)$(bindir)
	test -d $(DESTDIR)$(faustlibdir) || mkdir -p $(DESTDIR)$(faustlibdir)
	cp faustvst.cpp faustvstqt.h $(DESTDIR)$(faustlibdir)

uninstall-faust:
	rm -f $(DESTDIR)$(bindir)/faust2faustvst
	rm -f $(addprefix $(DESTDIR)$(faustlibdir)/, faustvst.cpp faustvstqt.h)

# Roll a distribution tarball.

DISTFILES = COPYING COPYING.LESSER Makefile README.md config.guess faust2faustvst faustvst.cpp faustvstqt.h Info.plist.in examples/*.dsp examples/*.lib examples/*.h

dist:
	rm -rf $(dist)
	for x in $(dist) $(dist)/examples; do mkdir $$x; done
	for x in $(DISTFILES); do ln -sf "$$PWD"/$$x $(dist)/$$x; done
	rm -f $(dist).tar.bz2
	tar cfjh $(dist).tar.bz2 $(dist)
	rm -rf $(dist)

distcheck: dist
	tar xfj $(dist).tar.bz2
	cd $(dist) && make SDK=$(abspath $(SDK)) && make install DESTDIR=./BUILD
	rm -rf $(dist)
