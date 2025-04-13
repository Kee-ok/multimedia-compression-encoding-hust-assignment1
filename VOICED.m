
% voicing_detector_magnitude_sum,
% voicing_detector_zero_crossing_detector function
% and pitch function are called in VOICED function

function [voiced, pitch_plot] = VOICED(x, fs, fsize);
f = 1;
%index no. of starting data point of current frame
b = 1;        
% Number data points in each framesize of "x"
frame_length = round(fs .* fsize);
% N+1 = frame_length = number of data points in each framesize
N = frame_length - 1;       
                           
%FRAME SEGMENTATION:
% "b+N" denotes the end point of current frame
% "y" denotes an array of the data points of the current frame
for b = 1 : frame_length : (length(x) - frame_length) , y1 = x(b : b + N);
    % Pre-emphasis filter
    y = filter([1 -.9378], 1, y1);
    % Call voicing_detector_magnitude_sum function
    msf(b : (b + N)) = voicing_detector_magnitude_sum(y);
    % Call voicing_detector_zero_crossing_detector function
    zc(b : (b + N)) = voicing_detector_zero_crossing_detector(y);
    % Call pitch function
    pitch_plot(b : (b + N)) = pitch(y, fs);
end

thresh_msf = (((sum(msf) ./ length(msf)) - min(msf)) .* (0.67)) + min(msf);
voiced_msf =  msf > thresh_msf;     %=1,0

thresh_zc = (((sum(zc) ./ length(zc)) - min(zc)) .*  (1.5)) + min(zc);
voiced_zc = zc < thresh_zc;

thresh_pitch = (((sum(pitch_plot) ./ length(pitch_plot)) - min(pitch_plot)) .* (0.5) ) + min(pitch_plot);
voiced_pitch =  pitch_plot > thresh_pitch;

for b = 1 : (length(x) - frame_length),
    if voiced_msf(b) .* voiced_pitch(b) .* voiced_zc(b) == 1,
        voiced(b) = 1;
    else
        voiced(b) = 0;
    end
end
voiced;
pitch_plot;
