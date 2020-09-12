import("stdfaust.lib");

////////////STEREO_INPUT////////////

stereoin = in
        with{
            fadergroup(x) = hgroup("Stereo input", x);
            fader = _ * (vslider("[01]vol", -96, -96, 12, 0.01) : ba.db2linear : si.smoo);
            meterL(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[02]L[unit:dB]", -96, +12));
            meterR(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[03]R[unit:dB]", -96, +12));
            in = _,_ : (fadergroup(fader) : fadergroup(meterR)),(fadergroup(fader) : fadergroup(meterL));
        };

////////////CANALI////////////

mixer(P) = mixergroup(par(i, P, ch(i+1)));
mixergroup(x) = hgroup("acusmonium", x);

 fader = slider
    with{
        fadergroup(x) = hgroup("fader", x);
        fader = _ * (vslider("[01]vol", -96, -96, 12, 0.01) : ba.db2linear : si.smoo);
        meter(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[02]METER[unit:dB]", -96, +12));
        slider = fadergroup(fader) : fadergroup(meter);
    };

equalizer = eqgroup(lsh : lowm: highm : hsh)
        with{
            eqgroup(x) = vgroup("[02]eq", x);
            highgroup(x) = hgroup("[01]him", x);
            lowgroup(x) = hgroup("[02]lowm", x);
            lp = nentry("[03]bass[style:knob]", 0, -24, 24, 0.01) : si.smoo;
            hp = nentry("[01]high[style:knob]", 0, -24, 24, 0.01) : si.smoo;
            lsh = fi.low_shelf(lp, 200);
            hsh = fi.high_shelf(hp, 10000);
            lowm = fi.peak_eq(pl, frq, bp)
                with{
                    q = 0.8;
                    bp = frq/q; //q costatante
                    frq = lowgroup(nentry("[01]frq1[style:knob][scale:lin]", 80, 80, 1900, 0.1) : si.smoo);
                    pl = lowgroup(nentry("[02]midbass[style:knob]", 0, -24, 24, 0.01) : si.smoo);
                };
            highm = fi.peak_eq(pl, frq, bp)
                with{
                    q = 0.8;
                    bp = frq/q; //q costatante
                    frq = highgroup(nentry("[01]frq2[style:knob][scale:lin]", 550, 550, 13000, 0.1) : si.smoo);
                    pl = highgroup(nentry("[02]midhigh[style:knob][unit:db]", 0, -24, 24, 0.01) : si.smoo);
                };
        };

      ch(v) = vgroup("[02]CH %v", equalizer : speakerpositiongroup(zita_light) : speakerpositiongroup(speakers) : fader);

////////////CONTROL_ROOM////////////

master = out
    with{
        fadergroup(x) = mastergroup(hgroup("fader", x));
        fader = _ * (vslider("[01]vol", -96, -96, 12, 0.01) : ba.db2linear : si.smoo);
        meterL(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[02]L[unit:dB]", -96, +12));
        meterR(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[03]R[unit:dB]", -96, +12));
        ef = _,_ <: dm.zita_light;
        mastergroup(x) = vgroup("master",x);
        out = (_,_) : mastergroup(ef) : (fadergroup(fader) : fadergroup(meterR)),(fadergroup(fader) : fadergroup(meterL));
    };

////////////SpeakerPosition////////////

    zita_light = hgroup("[02]Direction",(_ <: re.zita_rev1_stereo(rdel,f1,f2,t60dc,t60m,fsmax),_,_ :
	out_eq,_,_ : dry_wet :> filter))
with{
	fsmax = 48000.0;  // highest sampling rate that will be used
	rdel = 60;
	f1 = 200;
	t60dc = 3;
	t60m = 2;
	f2 = 6000;
	out_eq = pareq_stereo(eq1f,eq1l,eq1q) : pareq_stereo(eq2f,eq2l,eq2q);
	pareq_stereo(eqf,eql,Q) = fi.peak_eq_rm(eql,eqf,tpbt), fi.peak_eq_rm(eql,eqf,tpbt)
	with {
		tpbt = wcT/sqrt(max(0,g)); // tan(PI*B/SR), B bw in Hz (Q^2 ~ g/4)
		wcT = 2*ma.PI*eqf/ma.SR;  // peak frequency in rad/sample
		g = ba.db2linear(eql); // peak gain
	};
	eq1f = 315;
	eq1l = 0;
	eq1q = 3;
	eq2f = 1500;
	eq2l = 0;
	eq2q = 3;
	dry_wet(x,y) = *(wet) + dry*x, *(wet) + dry*y
	with {
		wet = 0.5*(drywet+1.0);
		dry = 1.0-wet;
	};
    position = (nentry("turn [style:knob]", 1, 0, 1, 0.01) : si.smoo);

    drywet = (1 - (-1)) * ((position - 0)/(1-0)) + (-1);

    filterscale = (20000 - 2000) * ((position - 0)/ (1 - 0)) + 2000;
    filter = fi.lowpass(1,filterscale);
};

speakerpositiongroup(x) = hgroup("[03]Speakers Position", x);

speakers = out
        with{
            out = _ : de.delay(ma.SR,del1) : fi.lowpass(1,fil1);
            speakergroup(x) = vgroup("[01]distance", x);
            del1 = speakergroup(pm.l2s(nentry("[03]METERS", 0,0,50,0.1)));
            fil1 = speakergroup(nentry("[01]lpf_1[style:knob]", 20000,0,20000,1)) : si.smoo;
        };

process = mixergroup(stereoin) <: mixer(2) :> mixergroup(master);
