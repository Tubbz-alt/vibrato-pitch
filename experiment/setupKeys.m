function keys = setupKeys()
  KbName('UnifyKeyNames');
  keys.right = KbName('RightArrow');
  keys.left = KbName('LeftArrow');
  keys.up = KbName('UpArrow');
  keys.down = KbName('DownArrow');
  keys.escape = KbName('ESCAPE');
  keys.space = KbName('Space');
  keys.return = KbName('Return')(1);
  keys.leftShift = KbName("LeftShift");
  keys.rightShift = KbName("RightShift");
  keys.leftControl = KbName("LeftControl");
  keys.rightControl = KbName("RightControl");
  RestrictKeysForKbCheck([ struct2cell(keys){:} ]);
end
