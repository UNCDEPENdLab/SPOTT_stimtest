function angle = StimNum(Parameters)

colorWheelRadius = 260; %radius of color wheel
colorWheelLocations1 = [cosd(1:360).*colorWheelRadius + Parameters.centerx; ...
    sind(1:360).*colorWheelRadius + Parameters.centery];


 [x,y] = GetMouse;
 
 num = (512 *2)/360;

   %find angle
 [~,angle] = min(sqrt((colorWheelLocations1(1,:)-x).^2 + (colorWheelLocations1(2,:)-y).^2));
 
 a = sqrt((Parameters.centerx-x)^2+(Parameters.centery-y)^2);
    if  a >= 266 || a <= 246
        angle = 361;
    end

