function experiment(sub)
  %% create stimuli
  stimuli = prepareStimuli();

  %% Setup structure
  % Set keys.
  keys = setupKeys();

  try
    ListenChar(2);
    InitializePsychSound(1);
    pahandle = PsychPortAudio('Open', [], [], 1, 48000, 2);

    %% show stimuli
    system('say Bitte beliebige Taste drücken.');
    KbStrokeWait();
    for i = 1:stimuli.rowcnt
      system("afplay Pop.aiff");
      stimuli(i, 3:5) = runTrial(keys, pahandle, stimuli(i, 1:2), stimuli(max(i-1, 1), 4:5));
    end% for

    %% collect answers
    result2csv(stimuli, sub);

  catch err
    disp(err.message);
  end
  %% close windows
  RestrictKeysForKbCheck([]);
  ListenChar(0);
  PsychPortAudio('Close', pahandle);
end
