classdef Tone
properties
pitch_Hz = 500;
startPhase_rad = 0;
amplitude = 0.5;
duration_s = 0.02;
fs_Hz = 48000;
end
methods
function display(self)
  printf("A %dHz tone\n", self.pitch_Hz);
end

function self = transpose(self, cent = 5)
  self.pitch_Hz = self.pitch_Hz*2^(cent/1200);
end

function self = volume(self, v)
  self.amplitude = Tone.clip(self.amplitude+v);
end

function dt_s = getDt(self)
  dt_s = 1/self.fs_Hz;
end

function n = n_samples(self)
  n = self.fs_Hz*self.duration_s;
end

function t_s = getTimeSteps(self)
  n = self.n_samples();
  t_s = linspace(0, self.duration_s, n+1);
  t_s = t_s(1:end-1);
end

function [ a, nextStartPhase ] = sine(self)
  t_s = self.getTimeSteps();
  a = self.amplitude*sin(self.startPhase_rad + 2*pi* self.pitch_Hz*t_s);
  nextStartPhase = mod(self.startPhase_rad + 2*pi* self.pitch_Hz*self.duration_s, 2*pi);
end

function phase_rad = nextStartPhase(self)
  phase_rad = mod(self.startPhase_rad + 2*pi* self.pitch_Hz*self.duration_s, 2*pi);
end

function self = move(self)
  self.startPhase_rad = self.nextStartPhase();
end
end

methods (Static = true)
function y = clip(x, bl = 0, bu = 1)
  y = min(max(x, bl), bu);
end% function

function cent = centDiff(obj1, obj2)
  cent = 1200/log(2)*log(obj1.pitch_Hz/obj2.pitch_Hz);
end

function t = randPitch()
  x = log2([ 250, 1000 ]);
  min = x(1); max = x(2);
  pitch_Hz = 2.^(min + (max-min)*rand(1));
  t = Tone();
  t.pitch_Hz = round(pitch_Hz);
end
end
end
