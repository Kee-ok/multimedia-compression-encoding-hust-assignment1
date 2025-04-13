% Main program body

clear all;
clc;

% Read .wav audio file
% x samples from audio with fs sampling frequency in [Hz]
[x, fs] = audioread('music(test).wav'); 

% Get length of audio in sec
% length(x) is sample length
t = length(x)./fs;
sprintf('Processing the wavefile non-compressed-audio.wav')
sprintf('The wavefile is  %3.2f  seconds long', t)

% ---------- The LPC algorithm ----------

%       x = audio samples
%       fs = sampling frequency
%       M = prediction order
%       aCoeff = LP coefficients
%       pitch_plot = pitch periods
%       voiced = voiced or unvoiced decision bit
%       gain = gain of frames

% Prediction order
M = 10;

% Call ENCODER function
[aCoeff, pitch_plot, voiced, gain] = ENCODER(x, fs, M);

% Call DECODER function
synth_speech = DECODER(aCoeff, pitch_plot, voiced, gain);

synth_speech(isnan(synth_speech)) = 0

% Plot figures
figure;
subplot(2,1,1), plot(x); 
title(['Original signal = "', 'recorded_audio', '"']); 
subplot(2,1,2), plot(synth_speech);
title(['synthesized speech of "', 'recorded_audio', '" using LPC algo']);
output_filename = 'music_lpc.wav';
audiowrite(output_filename, synth_speech, fs);
disp(['Lưu file tổng hợp thành công: ', output_filename]);