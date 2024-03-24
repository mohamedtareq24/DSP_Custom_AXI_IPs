function [ref_signal ,signal_acc, DELTAS, THETAS] = DDS_RM(LENGTH, CLKDIV, frequency, phase, AMPLS, Fclk,num_samples)
% Calculate sampling frequency
Fs = Fclk / CLKDIV; % Sampling frequency
DELTAS = round(frequency * 2^8 / Fs);
THETAS = round(phase * 2^16 / (2*pi));

% Generate time vector for 1 ms
time = 0:1/Fs:(num_samples -1)/Fs;

% Initialize composite signal
ref_signal = zeros(size(time));

% Generate composite signal
for i = 1:LENGTH
    % Calculate frequency of current component signal
    f_i = frequency(i);
    
    % Convert phase to radians
    theta_i = THETAS(i);
    
    % Generate component signal for four periods
    component_signal = AMPLS(i) * sin(2*pi*f_i*time + theta_i);
    
    % Add component signal to composite signal
    ref_signal = ref_signal + component_signal;
end
% Define the number of entries in the LUT
num_entries = 256;

% Calculate the step size for the angle in fixed-point representation
angle_step = fi(2*pi / num_entries, 1, 16, 15);

% Initialize an empty array to store the sine values in fixed-point format
sin_lut_fixed = fi(zeros(1, num_entries), 1, 16, 15);

% Generate the sine LUT in fixed-point format
for i = 1:num_entries
    angle = fi((i - 1) * angle_step, 0, 16, 12);
    sine_value = fi(sin(angle), 1, 16, 15); % Store as signed 16.8 fixed-point
    sin_lut_fixed(i) = sine_value;
end

out_signal = fi(zeros(1,num_samples),1,16,15);
sin_index_acc = fi(zeros(1,LENGTH),1,16,15);

signal_acc = 0;
for sample_number = 1:num_samples
    for ix = 1:LENGTH
        sin_index_acc(ix) = sin_index_acc(ix) + DELTAS(ix)/2^16 + THETAS(ix)/2^16; %% index accumaltor
        signal = sin_lut_fixed(int(sin_index_acc(ix)));
        signal_acc = signal_acc + signal ;
    end
    out_signal(sample_number) = signal_acc ;    %% the sample is out
    signal_acc = 0;                             %% clear the accumlator
end
end