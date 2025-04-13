% Clear command window, variables, and close all figures
clc; clear; close all;

%% 1. Read audio files
try
    % Read the original recorded audio
    [orig, fs_orig] = audioread('music_test(wav).wav');

    % Read the audio compressed with LPC
    [lpc_rec, fs_lpc] = audioread('music_lpc.wav');

    % Read the MP3-compressed audio
    [mp3_rec, fs_mp3] = audioread('music_test1(wav).mp3');
catch
    % If there's an error (e.g., missing file), display error message
    error('Unable to read audio files. Please check file paths and formats!');
end

% Check if sampling rates are different between files
if fs_orig ~= fs_lpc || fs_orig ~= fs_mp3
    warning('The files have different sampling rates! Results may be inaccurate.');
end

% Trim signals to the same length (use the shortest one)
min_len = min([length(orig), length(lpc_rec), length(mp3_rec)]);
orig = orig(1:min_len, 1);       % Original audio (mono)
lpc_rec = lpc_rec(1:min_len, 1); % LPC-compressed audio (mono)
mp3_rec = mp3_rec(1:min_len, 1); % MP3-compressed audio (mono)

%% 2. Calculate PSNR
psnr_lpc = calculate_psnr(orig, lpc_rec);   % PSNR: original vs LPC
psnr_mp3 = calculate_psnr(orig, mp3_rec);   % PSNR: original vs MP3

% Print PSNR results to Command Window
fprintf('PSNR Comparison Results:\n');
fprintf('--------------------------------\n');
fprintf('LPC:  %.2f dB\n', psnr_lpc);
fprintf('MP3: %.2f dB\n', psnr_mp3);
fprintf('--------------------------------\n');

% Create PSNR comparison table
psnr_table = table(psnr_lpc, psnr_mp3, ...
    'VariableNames', {'LPC', 'MP3'}, ...
    'RowNames', {'PSNR (dB)'});
disp('PSNR Comparison Table:');
disp(psnr_table);

%% 3. Plot comparison charts
% Bar chart for PSNR values
figure;
methods = {'LPC', 'MP3'};              % Method names
psnr_values = [psnr_lpc, psnr_mp3];   % PSNR values
bar(psnr_values);                     % Draw bar chart
set(gca, 'XTickLabel', methods);      % Set X-axis labels
ylabel('PSNR (dB)');
title('PSNR Comparison between LPC and MP3');
grid on;

% Plot waveforms of the signals
figure;
subplot(3,1,1);
plot(orig);                          % Original waveform
title('Original Audio');
xlim([1 length(orig)]);              % Set X-axis limits

subplot(3,1,2);
plot(lpc_rec);                       % LPC waveform
title(['LPC (PSNR = ', num2str(psnr_lpc), ' dB)']);
xlim([1 length(lpc_rec)]);

subplot(3,1,3);
plot(mp3_rec);                       % MP3 waveform
title(['MP3 (PSNR = ', num2str(psnr_mp3), ' dB)']);
xlim([1 length(mp3_rec)]);

%% 4. Frequency spectrum analysis
nfft = 2048;  % FFT size
% Hamming window for each frame
window = 0.54 - 0.46 * cos(2 * pi * (0:nfft-1)' / (nfft-1));
noverlap = nfft / 2;  % Overlap between frames

% Plot frequency spectra (spectrogram)
figure;
subplot(3,1,1);
plot_spectrum(orig, window, noverlap, nfft, fs_orig);
title('Original Audio Spectrum');

subplot(3,1,2);
plot_spectrum(lpc_rec, window, noverlap, nfft, fs_lpc);
title('LPC Compressed Audio Spectrum');

subplot(3,1,3);
plot_spectrum(mp3_rec, window, noverlap, nfft, fs_mp3);
title('MP3 Compressed Audio Spectrum');

%% Function to calculate PSNR
function psnr_value = calculate_psnr(original, compressed)
    mse = mean((original - compressed).^2);     % Mean Squared Error
    max_val = max(abs(original(:)));            % Max amplitude of original signal
    psnr_value = 10 * log10(max_val^2 / mse);   % PSNR formula
end

%% Function to plot frequency spectrum (spectrogram)
function plot_spectrum(signal, window, noverlap, nfft, fs)
    frame_length = length(window);   % Frame size
    % Number of frames
    num_frames = floor((length(signal) - frame_length) / (frame_length - noverlap)) + 1;
    spectrum = zeros(nfft/2, num_frames);  % Matrix to store FFT result

    for i = 1:num_frames
        start_index = (i-1) * (frame_length - noverlap) + 1;
        end_index = start_index + frame_length - 1;
        frame = signal(start_index:end_index) .* window;     % Apply Hamming window
        fft_result = fft(frame, nfft);                       % Compute FFT
        spectrum(:, i) = abs(fft_result(1:nfft/2));          % Store magnitude spectrum
    end

    % Plot spectrogram
    imagesc([1 num_frames], [0 fs/2], 20*log10(spectrum));
    axis xy;                % Display y-axis (frequency) from bottom to top
    xlabel('Time (frames)');
    ylabel('Frequency (Hz)');
    colorbar;               % Show color scale
    colormap jet;           % Use 'jet' colormap
end