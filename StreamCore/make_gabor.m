function gabor = make_gabor(isize, varargin)
%MAKE_GABOR makes greyscale gabor patches based on supplied input. The
%image output consists of a size x size square matrix of values from the
%interval [0 1] corresponding to grey values. Use as follows:
%
%   gabor = make_gabor(size, 'param1', val1, 'param2', val2...)
%
%   size is a scalar representing the pixel length of one size of the gabor
%patch. Available parameters are:
%   'norm_freq' - normalized spatial frequency. A value of 1 corresponds to
%one full cycle per the width of the total gabor size, a value of 0.5
%corresponds to two cycles per width, etc... (default is 0.1)
%   'orient_deg' - orientation in degrees. The orientation of the gabor is
%relative to the sinusoidal modulation. Isoluminant values run orthogonally
%to the orientation. That is, a value of 0 degrees corresponds to vertical
%lines, a value of 45 corresponds to diagonal lines running from upper-left
%to lower-right, etc. (default is 0)
%   'phase' - phase of sinusoid in radians. (default is 0)
%   'bg_contrast' - background contrast, must be a value from the interval
%[0 1]. This is the grey value of the pixels surrounding the sinusoidal
%grating. (default is 0.5, 50% grey)
%   'sigma' - kurtosis of the gaussian envelope. A value of one is good for
%most purposes. (default is 1)
%   'contrast' - modulation depth of sinusoidal grating, must be a value
%from [0 1]. A value of 1 corresponds to 100% contrast, a value of 0
%corresponds to no sinusoid at all. (default is 1)
%   'window' - function for windowing the sinusoidal grating. Can be
%'gauss' (gaussian window) or 'rectwin' (a hard circular edge).
%
%By: Adam Snyder 12/08 (asnyder@gc.cuny.edu).
%tic

p = inputParser;

p.addRequired('isize', @isscalar);
p.addParamValue('norm_freq', 0.1, @isscalar);
p.addParamValue('orient_deg', 0, @isscalar);
p.addParamValue('phase', 0, @isscalar);
p.addParamValue('bg_contrast', 0.5, @(x)x>=0&&x<=1);
p.addParamValue('sigma', 1, @isscalar);
p.addParamValue('contrast', 1, @(x)x>=0&&x<=1);
p.addParamValue('window','gauss',@isstr);


p.parse(isize, varargin{:});

% size = p.Results.size;
norm_freq = p.Results.norm_freq;
orient_deg = p.Results.orient_deg;
phase = p.Results.phase;
bg_contrast = p.Results.bg_contrast;
contrast = p.Results.contrast;
sigma = p.Results.sigma;
window = p.Results.window;

isize = round(isize);
[x y] = meshgrid(-floor(isize/2):ceil(isize/2)-1,-floor(isize/2):ceil(isize/2)-1);
orient = (orient_deg/180)*pi;
gabor = sin((cos(orient)*x*(1/norm_freq)/isize*2*pi)-(sin(orient)*y*(1/norm_freq)/isize*2*pi)+phase);

gabor = gabor*contrast;
gabor = (gabor+1)/2;
gabor = gabor-bg_contrast;
switch window
    case 'gauss'
        sigma = (sigma*pi)/(isize/2);
        gauss = (1/2*pi*(sigma.^2)).*exp(-(x.^2+y.^2)/2*(sigma.^2));
        rescale_factor = max(max(gauss));
        gauss = gauss/rescale_factor;
        gabor = gabor.*gauss;
    case 'rectwin'
        gabor(x.^2+y.^2>(isize./2).^2) = 0;
end;
gabor = gabor+bg_contrast;

%toc
end