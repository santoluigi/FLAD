s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels = 0;

(
{
var halafon;

	halafon = PanAz.ar(4, WhiteNoise.ar(0.5), LFSaw.kr(0.1));

}.scope;
{
var halafon;

	halafon = PanAz.ar(4, WhiteNoise.ar(0.5), LFSaw.kr(-0.01, 0.5));

}.scope;
)

