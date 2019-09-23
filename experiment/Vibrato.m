classdef Vibrato < Tone
properties
modRate_Hz = 10;
depth_Cent = 150;
peak = 'high';
stable_rel = 0.5;
startSample = 1; % Index im Frequenzvektor
end
properties (access=private)
extremes_Hz = [ 0, 0 ];
modCycle_Hz = [];
modSequence_Hz = [];
end
methods
function self = Vibrato(peak, stable_rel)
  if nargin() == 2
    self.peak = peak;
    self.stable_rel = stable_rel;
  end
  self = self.recalc();
end

function display(self)
  printf ([ ...
    "A sinusoid with trapezoidal frequency modulation\n\n", ...
    "geometric mean: %dHz\n", ...
    "modulation rate: %dHz\n", ...
    "overall depth: %d Cent\n\n", ...
    "The peaks point to the %s frequencies.\n" ...
  ], self.pitch_Hz, self.modRate_Hz, self.depth_Cent, self.peak);
end

function self = recalc(self, extremes_Hz)
  if nargin() == 2
    self.extremes_Hz = extremes_Hz;
  else
    self.extremes_Hz = self.getExtremes();
  end% if
  self.modCycle_Hz = self.getModCycle();
  self.modSequence_Hz = self.getModSequence();
end

function a = ratio(self)
  a = 2^(self.depth_Cent/1200);
end

function extremes_Hz = getExtremes(self)
  a = self.ratio();
  alpha = (a^(1/(1-1/a))) / exp(1);
  p = self.stable_rel;
  extremes_Hz = [ 0, 0 ];
  switch self.peak
  case "low"
    extremes_Hz(1) = self.pitch_Hz * a^(-p) * alpha^(p-1);
  case "high"
    extremes_Hz(1) = self.pitch_Hz * alpha^(p-1);
  end% switch
  extremes_Hz(2) = a*extremes_Hz(1);
end

function [ x, y ] = trapez(self)
  lowFreq_Hz = self.extremes_Hz(1);
  highFreq_Hz = self.extremes_Hz(2);
  x = zeros(1, 4);
  x(1) = 0;
  x(4) = 1;
  x(2) = (1-self.stable_rel)/2;
  x(3) = x(2) + self.stable_rel;
  x = x/self.modRate_Hz;
  y = zeros(1, 4);
  switch self.peak
    case "high"
      y = [ highFreq_Hz, lowFreq_Hz, lowFreq_Hz, highFreq_Hz ];
    case "low"
      y = [ lowFreq_Hz, highFreq_Hz, highFreq_Hz, lowFreq_Hz ];
  end% switch
end

function n = mod_samples(self)
  n = self.fs_Hz/self.modRate_Hz;
end

function freq = getModCycle(self)
  [ x, y ] = self.trapez();
  n = self.mod_samples();
  XI = linspace(x(1), x(end), n+1);
  freq = interp1(x, y, XI(1:end-1), "linear");
end

function freq = getModSequence(self)
  freq = self.modCycle_Hz;
  n_samples = self.n_samples();
  n_mod = ceil(n_samples/length(freq))+1; % bewusst mehr als benötigt, zum gut rausslicen
  freq = repmat(freq, 1, n_mod);
end

function freq = getModSlice(self)
  n_samples = self.n_samples();
  freq = self.modSequence_Hz(self.startSample:self.startSample+n_samples-1);
end

function [ a, nextStartPhase ] = sine(self)
  step_rad = 2*pi*self.getDt();
  freq = self.getModSlice();
  phase_rad = cumsum([ self.startPhase_rad, step_rad*freq ]);
  nextStartPhase = mod(phase_rad(end), 2*pi);
  a = self.amplitude*sin(phase_rad(1:end-1));
end

function phase_rad = nextStartPhase(self)
  phase_rad = mod(sum([ self.startPhase_rad, 2*pi*pitch_Hz*self.getDt() ]), 2*pi);
end

function self = move(self, nextStartPhase)
  if nargin() == 2
    self.startPhase_rad = nextStartPhase;
  else
    self.startPhase_rad = self.getNextStartPhase();
  end% if
  n_samples = self.n_samples();
  self.startSample = mod(self.startSample + n_samples-1, self.mod_samples())+1;
end% function
end% methods
end% classdef
