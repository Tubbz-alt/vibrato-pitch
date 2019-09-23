function result2csv(stimuli, sub)
  c = stimuli.cell;
  filepath = fullfile("..", "data", strcat([ "result_", sub, ".csv" ]));
  cell2csv(filepath, c(:, 3:7));
end
