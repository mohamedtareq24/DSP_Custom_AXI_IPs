clear;
clc;
fund_freq = 1000;
%%
%%FPGA  CLK
Fclk = 100e6;
num_samples = 1024;
%% DDS Registers
LENGTH  = 15;                  
CLKDIV  = 500;               
AMPLS   = zeros(1,LENGTH);
%DELTAS  = zeros(1,LENGTH);
%THETAS  = zeros(1,LENGTH);

% Number of harmonics
num_harmonics = LENGTH;
% Initialize signal
frequency = zeros(1,LENGTH);
% Generate signal by superimposing sinusoids
for n = 0:1:LENGTH-1
    % Calculate harmonic frequency
    frequency(n+1) = (2*n+1)*fund_freq;
    
    % Calculate harmonic coefficient
    AMPLS(n+1) = 1 / (2*n+1);
end
%%
Fs = Fclk / CLKDIV ;
if (CLKDIV <= LENGTH)
    error_message = sprintf('CLKDIV canot be >= LENGTH');
    disp(error_message);
elseif (max(frequency) > Fs /2 ) 
    error_message = sprintf('ERROR: Maximum frequency is %.2e Hz while Fs is %.2e Hz.', max(frequency), Fs);
    disp(error_message);
else
phase = zeros(1,LENGTH);
[ref_signal ,signal_acc, DELTAS, THETAS] = DDS_RM(LENGTH, CLKDIV, frequency, phase, AMPLS, Fclk,num_samples);
    if(min(DELTAS)==0)
            error_message = sprintf('MIN DELTAS = 0 Fs is %.2e Hz',Fs);
            disp(error_message);
    else
        info_messege = sprintf('Fs is %d Hz',Fs);
        display(info_messege);
        plot(ref_signal);
    end
hold on     
% Convert inputs to fixed-point
AMPLS_fixed     = fi(AMPLS, 1, 16, 15);
THETAS_fixed    = fi(THETAS,1,16,15);
signal_acc = fi(signal_acc,1,16,15);
stem(signal_acc);
end
