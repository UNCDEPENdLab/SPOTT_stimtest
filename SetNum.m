function setx = SetNum(window)

 [x, y] = GetMouse;
  set = (960 *2)/8;
 setx = min(8,ceil(x/set));