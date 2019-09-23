## @knitr fitVibrato
function err = errorfun(a, v)
  extremes_Hz = [ a, v.ratio() * a ];
  v = v.recalc(extremes_Hz);
  m = mean(v.modCycle_Hz, "g");
  err = (v.pitch_Hz - m)^2;
end
cd matlab;
v = Vibrato();
fprintf("Analytic f_0: %d\n", v.extremes_Hz(1));
[ a, err ] = fminsearch(@(a) errorfun(a, v), 300);
fprintf("Estimated f_0: %d\nerror: %d\n", a, err);