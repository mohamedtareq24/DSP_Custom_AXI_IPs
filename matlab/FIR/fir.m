clc;
clear;
% FIR Low-pass Filter Design using Hamming Window
%https://chat.openai.com/share/3ede23dc-11d1-4a85-b5b7-0659a86a3e7a
% Specifications
order = 52;                     % Filter order
cutoff_frequency = 3.5e3;       % Cutoff frequency in Hz
sampling_rate = 48.00e3;         % Sampling rate in Hz
num_points = 1024 ;

% Design the FIR filter using Hamming window
fir_coefficients = fir1(order, cutoff_frequency/(sampling_rate/2), 'low', hamming(order + 1));

% Display the coefficients
%disp('FIR Coefficients:');
%disp(fir_coefficients);

% Time vector
t = 0:1/sampling_rate:(num_points-1)*1/sampling_rate;

% Generate signals
signal = 0.8*(sin(2*pi*1000*t));
noise = 0.1*sin(2*pi*40000*t) + 0.05*sin(2*pi*50000*t);
noisy_signal = noise + signal;

filtered_noisy_signal = filter(fir_coefficients, 1, noisy_signal);
%filtered_noise = filter(fir_coefficients, 1, noise);
%filtered_signal = filter(fir_coefficients, 1, signal);

fir_coefficients_fixed = fi(fir_coefficients, true, 16, 15);
filtered_noisy_signal_fixed = fi(filtered_noisy_signal, true, 16, 15);
noisy_signal_fixed = fi(noisy_signal, true, 16, 15);

% Write content to files in hexadecimal format
write_to_file(fir_coefficients_fixed, 'D:\Digital_Electronics\DSP\DSP_course\dv\FIR\fir_coefficients.hex');
write_to_file(noisy_signal_fixed, 'D:\Digital_Electronics\DSP\DSP_course\dv\FIR\noisy_signal.hex');
write_to_file(filtered_noisy_signal_fixed, 'D:\Digital_Electronics\DSP\DSP_course\dv\FIR\filtered_noisy_signal.hex');


% Plot original signal
figure;
subplot(2, 1, 1);
plot(t, noisy_signal);
title('Original Signal (Before Filtering)');
xlabel('Time (s)');
ylabel('Amplitude');

% Plot filtered signal
subplot(2, 1, 2);
plot(t, filtered_noisy_signal);
title('Filtered Signal (After Filtering)');
xlabel('Time (s)');
ylabel('Amplitude');