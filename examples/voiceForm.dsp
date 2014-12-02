declare name "Voice Formant";
declare description "Voice Formant Instrument";
declare author "Romain Michon (rmichon@ccrma.stanford.edu)";
declare copyright "Romain Michon";
declare version "1.0";
declare license "STK-4.3"; // Synthesis Tool Kit 4.3 (MIT style license);
declare description "This instrument contains an excitation singing wavetable (looping wave with random and periodic vibrato, smoothing on frequency, etc.), excitation noise, and four sweepable complex resonances. Phoneme preset numbers: 0->eee (beet), 1->ihh (bit), 2->ehh (bet), 3->aaa (bat), 4->ahh (father), 5->aww (bought), 6->ohh (bone), 7->uhh (but), 8->uuu (foot), 9->ooo (boot), 10->rrr (bird), 11->lll (lull), 12->mmm (mom), 13->nnn (nun), 14->nng (sang), 15->ngg (bong), 16->fff, 17->sss, 18->thh, 19->shh, 20->xxx, 21->hee (beet), 22->hoo (boot), 23->hah (father), 24->bbb, 25->ddd, 26->jjj, 27->ggg, 28->vvv, 29->zzz, 30->thz, 31->zhh";
declare nvoices "16";

import("music.lib");
import("oscillator.lib");
import("instrument.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("h:Basic_Parameters/freq [1][unit:Hz] [tooltip:Tone frequency]",440,20,20000,1);
gain = nentry("h:Basic_Parameters/gain [1][tooltip:Gain (value between 0 and 1)]",1,0,1,0.01); 
gate = button("h:Basic_Parameters/gate [1][tooltip:noteOn = 1, noteOff = 0]");

phoneme = hslider("v:Physical_Parameters/Phoneme
[2][lv2:integer][lv2:scalepoint eee 0 ihh 1 ehh 2 aaa 3 ahh 4 aww 5 ohh 6 uhh 7 uuu 8 ooo 9 rrr 10 lll 11 mmm 12 nnn 13 nng 14 ngg 15 fff 16 sss 17 thh 18 shh 19 xxx 20 hee 21 hoo 22 hah 23 bbb 24 ddd 25 jjj 26 ggg 27 vvv 28 zzz 29 thz 30 zhh 31]",4,0,31,1);

vibratoFreq = hslider("h:Envelopes_and_Vibrato/v:Vibrato_Parameters/Vibrato_Freq 
[3][unit:Hz]",6,1,15,0.1);
vibratoGain = hslider("h:Envelopes_and_Vibrato/v:Vibrato_Parameters/Vibrato_Gain
[3][tooltip:A value between 0 and 1]",0.05,0,1,0.01);
vibratoBegin = hslider("h:Envelopes_and_Vibrato/v:Vibrato_Parameters/Vibrato_Begin
[3][unit:s][tooltip:Vibrato silence duration before attack]",0.05,0,2,0.01);
vibratoAttack = hslider("h:Envelopes_and_Vibrato/v:Vibrato_Parameters/Vibrato_Attack 
[3][unit:s][tooltip:Vibrato attack duration]",0.5,0,2,0.01);
vibratoRelease = hslider("h:Envelopes_and_Vibrato/v:Vibrato_Parameters/Vibrato_Release 
[3][unit:s][tooltip:Vibrato release duration]",0.1,0,2,0.01);

voicedEnvelopeAttack = hslider("h:Envelopes_and_Vibrato/v:Envelope_Parameters/Voiced_Attack
[4][unit:s][tooltip:Voiced sounds attack duration]",0.01,0,2,0.01);
voicedEnvelopeRelease = hslider("h:Envelopes_and_Vibrato/v:Envelope_Parameters/Voiced_Release
[4][unit:s][tooltip:Voiced sounds release duration]",0.01,0,2,0.01);

noiseEnvelopeAttack = hslider("h:Envelopes_and_Vibrato/v:Envelope_Parameters/Noised_Attack
[4][unit:s][tooltip:Noised sounds attack duration]",0.001,0,2,0.001);
noiseEnvelopeRelease = hslider("h:Envelopes_and_Vibrato/v:Envelope_Parameters/Noised_Release
[4][unit:s][tooltip:Noised sounds release duration]",0.001,0,2,0.001);

//==================== SIGNAL PROCESSING ================

//----------------------- Synthesis parameters computing and functions declaration ----------------------------

//stereoizer is declared in instrument.lib and implement a stereo spacialisation in function of 
//the frequency period in number of samples 
stereo = stereoizer(SR/freq);

//exitation filters (declared in instrument.lib)
onePoleFilter = onePole(b0,a1)
	with{
		pole = 0.97 - (gain*0.2);
		b0 = 1 - pole;
		a1 = -pole;	
	};
oneZeroFilter = oneZero1(b0,b1)
	with{
		zero = -0.9;
		b0 = 1/(1 - zero);
		b1 = -zero*b0;
	};

//implements a formant (resonance) which can be "swept" over time from one frequency setting to another
formSwep(frequency,radius,filterGain) = *(gain_) : bandPass(frequency_,radius)
	with{
		//filter's radius, gain and frequency are interpolated
		radius_ = radius : smooth(0.999);
		frequency_ = frequency : smooth(0.999);
		gain_ = filterGain : smooth(0.999);
	};

//formants parameters are countained in a C++ file
phonemeGains = ffunction(float loadPhonemeGains(int,int), <stklib.h>,"");
phonemeParameters = ffunction(float loadPhonemeParameters(int,int,int), <stklib.h>,"");

//formants frequencies
ffreq0 = phonemeParameters(phoneme,0,0);
ffreq1 = phonemeParameters(phoneme,1,0);
ffreq2 = phonemeParameters(phoneme,2,0);
ffreq3 = phonemeParameters(phoneme,3,0);

//formants radius
frad0 = phonemeParameters(phoneme,0,1);
frad1 = phonemeParameters(phoneme,1,1);
frad2 = phonemeParameters(phoneme,2,1);
frad3 = phonemeParameters(phoneme,3,1);

//formants gains
fgain0 = phonemeParameters(phoneme,0,2) : pow(10,(_/20));
fgain1 = phonemeParameters(phoneme,1,2) : pow(10,(_/20));
fgain2 = phonemeParameters(phoneme,2,2) : pow(10,(_/20));
fgain3 = phonemeParameters(phoneme,3,2) : pow(10,(_/20));

//gain of the voiced part od the sound
voiceGain = phonemeGains(phoneme,0) : smooth(0.999);

//gain of the fricative part of the sound 
noiseGain = phonemeGains(phoneme,1) : smooth(0.999);

//formants filters
filter0 = formSwep(ffreq0,frad0,fgain0);
filter1 = formSwep(ffreq1,frad1,fgain1);
filter2 = formSwep(ffreq2,frad2,fgain2);
filter3 = formSwep(ffreq3,frad3,fgain3);

//----------------------- Algorithm implementation ----------------------------

//envelopes (declared in instrument.lib) and vibrato
vibratoEnvelope = envVibrato(vibratoBegin,vibratoAttack,100,vibratoRelease,gate);
voicedEnvelope = asr(voicedEnvelopeAttack,100,voicedEnvelopeRelease,gate);
noiseEnvelope = asr(noiseEnvelopeAttack,100,noiseEnvelopeRelease,gate);
vibrato = osc(vibratoFreq)*vibratoGain*100*vibratoEnvelope;

//the voice source is generated by an impulse train
//(imptrain defined in oscillator.lib) that is lowpass filtered
voiced = imptrain(freq+vibrato) : lowpass3e(3300) : *(voiceGain*voicedEnvelope);

//ficative sounds are produced by a noise generator
frica = noise*noiseEnvelope*noiseGain;

process = stkmain((voiced : oneZeroFilter : onePoleFilter : 
		 +(frica) <: filter0,filter1,filter2,filter3 :> + : stereo : 
		 instrReverb));

