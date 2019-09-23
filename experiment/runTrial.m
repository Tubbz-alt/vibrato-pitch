function result = runTrial(keys, pahandle, stimulus, amplitudes)
  % Setup tuning variables
  isTuning = true;
  sinus = Tone.randPitch();
  if isfinite(amplitudes.amplitude_sinus)
    sinus.amplitude = amplitudes.amplitude_sinus;
  end
  vibrato = Vibrato(stimulus.peak, stimulus.stable_rel);
  if isfinite(amplitudes.amplitude_vibrato)
    vibrato.amplitude = amplitudes.amplitude_vibrato;
  end

  PsychPortAudio("UseSchedule", pahandle, 1, 2);
  [ nextStartPhase, defaultBuffer ] = shiftPhase(pahandle, sinus, vibrato);
  tryPushNext;
  tryPushNext;
  PsychPortAudio('Start', pahandle, 0, 0, 1, inf, 1);
  KbReleaseWait;
  [ ~, ~, oldKeyCode ] = KbCheck();
  
  while isTuning
    [ keyIsDown, secs, keyCode ] = KbCheck();
    if any(keyCode ~= oldKeyCode)
      oldKeyCode = keyCode;
    firstKey = find(keyCode, 1);

      if keyIsDown
      switch firstKey
        case keys.right
        sinus = sinus.transpose(getCent(keys, keyCode));
        [ nextStartPhase, defaultBuffer ] = shiftPhase(pahandle, sinus, vibrato);
      case keys.left
        sinus = sinus.transpose(-1 * getCent(keys, keyCode));
        [ nextStartPhase, defaultBuffer ] = shiftPhase(pahandle, sinus, vibrato);
      case keys.up
        if any(keyCode([keys.leftShift, keys.rightShift]))
          vibrato = vibrato.volume(0.1);
      else
        sinus = sinus.volume(0.1);
      end% if
      case keys.down
        if any(keyCode([keys.leftShift, keys.rightShift]))
          vibrato = vibrato.volume(-0.1);
      else
        sinus = sinus.volume(-0.1);
      end% if
      case keys.space
        resume(pahandle);
        case keys.return
        isTuning = false;
        result = [ sinus.pitch_Hz, sinus.amplitude, vibrato.amplitude ];
        case keys.escape
        error("Experiment interrupted");
      end% switch
      end % if ...
    end% if
  tryPushNext();
  pause(0.001);
  end% while
  PsychPortAudio('Stop', pahandle);

  function success = tryPushNext()
    [ success, freeSlots ] = PsychPortAudio("AddToSchedule", pahandle, defaultBuffer);
    if success
      sinus = sinus.move(nextStartPhase.sinus);
      vibrato = vibrato.move(nextStartPhase.vibrato);
      [ nextStartPhase, defaultBuffer ] = shiftPhase(pahandle, sinus, vibrato);
    end% if
  end% function

end% function

function [ nextStartPhase, defaultBuffer ] = shiftPhase(pahandle, sinus, vibrato)
  [ sinusData, nextStartPhase.sinus ] = sinus.sine();
  [ vibratoData, nextStartPhase.vibrato ] = vibrato.sine();
  defaultBuffer = PsychPortAudio("CreateBuffer", pahandle, [ vibratoData; sinusData ]);
end

function cent = getCent(keys, keyCode)
  cent = 5;
  if any(keyCode([keys.leftShift, keys.rightShift]))
    cent = 100;
  end% if
  if any(keyCode([keys.leftControl, keys.rightControl]))
    cent = 1;
  end% if
end% function

function resume(pahandle)
  PsychPortAudio('Stop', pahandle);
  system('say Zum Fortsetzen bitte beliebige Taste drücken.');
  KbStrokeWait();
  system("afplay Pop.aiff");
  PsychPortAudio('Start', pahandle, 0, 0, 1, inf, 1);
end% function
