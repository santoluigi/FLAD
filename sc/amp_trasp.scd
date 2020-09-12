
i = {SoundIn.ar};


(
{
var cut1, cut2, cut3, cut4;
var coff;
var delay1, delay2, delay3, delay4;
var lp1, lp2, lp3, lp4;
var sec1,sec2, sec3, sec4;

cut1 = z.value(5000);  // cutoff lpf 1
cut2 = z.value(5000);  // cutoff lpf 2
cut3 = z.value(1000);  // cutoff lpf 3
cut4 = z.value(100);  // cutoff lpf 4

sec1 = 1; // ritardo dly 1
sec2 = 0.2; // ritardo dly 2
sec3 = 0.4; // ritardo dly 3
sec4 = 0.5; // ritardo dly 4

z = {   // coefficenti filtro onepole
	arg h;
	a = s.sampleRate;
	b = 2 - (cos(2*pi*(h/a)));
	d = b - sqrt((b*b)-1.0);
};


delay1 = {DelayL.ar(i, 1, sec1, mul:(1-cut1))};	// delay ch 1
delay2 = {DelayL.ar(i, 1, sec2, mul:(1-cut2))};	// delay ch 2
delay3 = {DelayL.ar(i, 1, sec3, mul:(1-cut3))};	// delay ch 3
delay4 = {DelayL.ar(i, 1, sec4, mul:(1-cut4))};	// delay ch 4

lp1 = {OnePole.ar(delay1, cut1)};  // lpf ch 1.new
lp2 = {OnePole.ar(delay2, cut2)};  // lpf ch 2
lp3 = {OnePole.ar(delay3, cut3)};  // lpf ch 3
lp4 = {OnePole.ar(delay4, cut4)};  // lpf ch

//Interfaccia Grafica

w = Window.new("amp_trsp", Rect.new(750,50,500,200));
w.front;
w.alwaysOnTop = true;

~slider = Slider.new(w.view, Rect.new(20, 20, 150, 30));
~slider.action

//Outs

[lp1, lp2, lp3, lp4];
}.scope
)

ServerOptions.inDevices.postln;
Server.default.options.inDevice_("Built-in Microph");