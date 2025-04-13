function [aCoeff, pitch_plot, voiced, gain] = ENCODER(x, fs, M);

% nargin returns the number of function input arguments
if (nargin < 3) , M = 10;
end

% Index no. of starting data point of current frame
b = 1;
% Frame size
fsize = 30e-3;
% Number data points in each framesize of "x"
frame_length = round(fs .* fsize);    
% N+1 = frame_length = number of data points in each framesize
N = frame_length - 1;

%       x = audio samples
%       fs = sampling frequency
%       fsize = frame size
%       pitch_plot = pitch periods
%       voiced = voiced or unvoiced decision bit

% Call VOICED/UNVOICED function[independent of frame segmentation]
[voiced, pitch_plot] = VOICED(x, fs, fsize);

%FRAME SEGMENTATION for aCoeff and GAIN;
% "b+N" denotes the end point of current frame
% "y" denotes an array of the data points of the current frame
for b = 1 : frame_length : (length(x) - frame_length),
    y1 = x(b : b + N);
    % Pre-emphasis filtering
    y = filter([1 -.9378], 1, y1);

    % aCoeff [LEVINSON-DURBIN METHOD];
    % e = error signal from levinson_durbin proc
    [a, tcount_of_aCoeff, e] = levinson_durbin(y, M);
    % aCoeff is array of "a" for whole "x"
    aCoeff(b : (b + tcount_of_aCoeff - 1)) = a;  

    %GAIN;
        pitch_plot_b = pitch_plot(b); %pitch period
        voiced_b = voiced(b);
    gain(b) = GAIN(e, voiced_b, pitch_plot_b);
end
