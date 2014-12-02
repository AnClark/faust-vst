
/* A simple waveshaping effect. This is based on Bram de Jong's code from
   musicdsp.org (http://www.musicdsp.org/archive.php?classid=4#41). */

declare name "waveshaper";
declare author "Albert Graef";
declare description "simple waveshaping/distortion effect";
declare version "1.0";

import("music.lib");

dist	= hslider("distortion", 30, 0, 50, 0.1);	// distortion parameter
gain	= hslider("gain", 3, -20, 20, 0.1);		// output gain (dB)

// the waveshaping function
f(a,x)	= x*(abs(x) + a)/(x*x + (a-1)*abs(x) + 1);

// gain correction factor to compensate for distortion
g(a)	= 1/sqrt(a+1);

process	= vgroup("dist", (out, out))
with { out(x) = db2linear(gain)*g(db2linear(dist))*f(db2linear(dist),x); };
