(
{
var cut;


z = {   // coefficenti filtro onepole
	arg h;
	a = s.sampleRate;
	b = 2 - (cos(2*pi*(h/a)));
	d = b - sqrt((b*b)-1.0);
};

cut = z.value(500);

i = {WhiteNoise.ar(1-cut)};

{OnePole.ar(i, cut)}.scope
}.scope
)