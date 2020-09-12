
(
{
r = {SinOsc.ar(0.3).range(0.1, 1)};

x = {WhiteNoise.ar(0.5)};

u = LocalIn.ar(1);

p = {AllpassL.ar((x + (u * 1)), 1, r)};

h = {AllpassL.ar(p, 1, r)};

a = {AllpassL.ar(h, 1, r)};

s = {AllpassL.ar(a, 1, r)};

l = LocalOut.ar(s);

Out.ar([0,1], (x + s)*0.6)}.scope;
)

(
{

var input, fBLoopIn, fBLoopOut, processing;

input = Impulse.ar(0);

fBLoopIn = LocalIn.ar(1);

processing = input + DelayL.ar((fBLoopIn * 0.9), 1, 0.5);

p = LPF.ar(processing, 220);

fBLoopOut= LocalOut.ar(p);

Out.ar([0,1], processing)}.play
)
