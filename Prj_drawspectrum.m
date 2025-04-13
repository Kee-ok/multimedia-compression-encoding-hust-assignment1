% 1.Load an audio
% Load recorded audio (WAV file)
[audioSignal, Fs] = audioread('recorded_audio.wav'); 
% Fs = sampling frequency

% Optional: Make it mono if it's stereo
if size(audioSignal, 2) > 1
    audioSignal = mean(audioSignal, 2);
end

% 2.Compute and plot the spectrum
% Compute FFT
N = length(audioSignal);                % Length of signal
Y = fft(audioSignal);                   % Compute FFT
f = Fs*(0:N/2-1)/N;                     % Frequency vector (one-sided)

% Normalize and get magnitude
Y_mag = abs(Y/N);
Y_mag = Y_mag(1:N/2);                   % One-sided spectrum

% Plot spectrum
figure;
plot(f, Y_mag);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Magnitude Spectrum of Recorded Audio');
grid on;
% 3.Comment on Energy Distribution
% Convert to decibels
Y_db = 20*log10(Y_mag + eps); % eps to avoid log(0)

figure;
plot(f, Y_db);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Log-Magnitude Spectrum (dB) of Recorded Audio');
grid on;
% 4.Interpretation / Comments
% Compute energy in bands
energy_total = sum(Y_mag.^2);
energy_low = sum(Y_mag(f < 500).^2) / energy_total;
energy_mid = sum(Y_mag(f >= 500 & f < 2000).^2) / energy_total;
energy_high = sum(Y_mag(f >= 2000).^2) / energy_total;

fprintf('Low-frequency energy: %.2f%%\n', energy_low * 100);
fprintf('Mid-frequency energy: %.2f%%\n', energy_mid * 100);
fprintf('High-frequency energy: %.2f%%\n', energy_high * 100);

