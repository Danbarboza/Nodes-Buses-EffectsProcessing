// Assignment 3


(
SynthDef(\rvb,{ arg inBus=16,size=1,damp=0.5,amp=1;
	Out.ar(0,FreeVerb.ar(In.ar(inBus,1),1,size, damp,amp).dup)
}).store;

SynthDef(\dly,{ arg inBus=16,mxdly=5,dlytime=2, decay=0.05,amp=0.25;
	Out.ar(0,AllpassN.ar(In.ar(inBus,1),mxdly,dlytime,decay,amp).dup);
}).store;

SynthDef(\combDelay,{ arg inBus=16,delay=0.5,decay=4,amp=1;
	Out.ar(0,CombN.ar(In.ar(inBus,1),1.0,delay,decay).dup,amp)
}).store;

SynthDef(\bpf,{ arg inBus=16,ffrq=220,bpfQ=0.5,amp=1;
	Out.ar(0,BPF.ar(In.ar(inBus,1),ffrq,bpfQ,amp).dup);
}).store;

//My Synth
SynthDef(\tank,{
	arg effBus=16, eff1Amp=0, eff2Amp=0, eff3Amp=0, eff4Amp=0, amp = 0.2, spd=10, ffrq=80,bwr=1, gate=1;
	var sig = SinOsc.ar(Pulse.kr(spd).range(100,440),0.25,amp);
	sig = Resonz.ar(sig,SinOsc.kr(ffrq).range(100,1000),bwr);
	Out.ar(effBus,[sig*eff1Amp, sig*eff2Amp, sig*eff3Amp, sig*eff4Amp]);
	Out.ar(0,(sig*amp).dup);
}).store;

)


(
~effGroup = Group.tail(1);
~effBus = (rvb: Bus.audio(s,1), dly: Bus.audio(s,1), delay: Bus.audio(s,1), bpf:Bus.audio(s,1)  );
)



(
Pdef(\tanker,
	Ppar([
		Pbind(\instrument,\tank,
			\group,1,
			\amp, 1,
			\effBus, ~effBus[\rvb],
			\freq, Pseq([200,400,200,800,1200,600],8),
			\range,127/128,
			\spd,0.5,
			\amp, 0.2,
			\eff2Amp, Pxrand([0.25,0.125,1,0.75,0.5,0.875]*0.2,8),
			\pitchdecay, 0.001,
			\eff3Amp, Pseq([0.5,0,0.2,0,0.5,0,0.7,0],8),
			\dur, Prand([0.33,0.66,1.0,0.33],8)
		),
		Pmono(\combDelay,
			\group,~effGroup,
			\inBus, ~effBus[\delay],
			\amp, 1,
			\time, 2,
			\decay, 2,
			\dur,2
		),
		Pmono(\bpf,
			\group,~effGroup,
			\inBus, ~effBus[\bpf],
			\freq,Pwhite(30,1760),
			\decay,0.02,
			\amp,0.5,
			\dur,2
		)
]));
)
Pdef(\tanker).play
Pdef(\tanker).stop