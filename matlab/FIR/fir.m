% FIR Low-pass Filter Design using Hamming Window

% Specifications
order = 50;                     % Filter order
cutoff_frequency = 3.5e3;       % Cutoff frequency in Hz
sampling_rate = 44.1e3;         % Sampling rate in Hz

% Design the FIR filter using Hamming window
fir_coefficients = fir1(order, cutoff_frequency/(sampling_rate/2), 'low', hamming(order + 1));

% Display the coefficients
%disp('FIR Coefficients:');
%disp(fir_coefficients);

% Time vector
t = 0:1/sampling_rate:0.005;

% Generate signals
signal = 5*(sin(2*pi*1000*t));
noise = sin(2*pi*40000*t) + 0.5*sin(2*pi*50000*t);
noisy_signal = noise + signal;

filtered_noisy_signal = filter(fir_coefficients, 1, noisy_signal);
%filtered_noise = filter(fir_coefficients, 1, noise);
%filtered_signal = filter(fir_coefficients, 1, signal);

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