% Define the time vector
t = 0:1/50000:0.004;

% Generate the signal
signal = (sin(2*pi*1000*t)).*(0.8*cos(2*pi*2000*t));
noise = sin(2*pi*40000*t)+0.5*sin(2*pi*50000*t);
noisy_signal = noise + signal ;

% Scale the signal to fit within the range of a 16-bit integer
scaled_signal = int16(noisy_signal * (2^15 - 1));

% Convert the scaled signal to binary representation
binary_signal = dec2bin(typecast(scaled_signal, 'uint16'), 16);

% Save each 16-bit binary value on a separate line in the text file
% fileID = fopen('binary_noisy_signal.txt', 'w');
% for i = 1:size(binary_signal, 1)
%     fprintf(fileID, '%s\n', binary_signal(i, :));
% end
% fclose(fileID);

% Plot the original signal in time domain
figure('Position', [100, 200, 2500, 600]);
plot(t, noisy_signal);
title('Original Signal in Time Domain');
xlabel('Time (s)');
ylabel('Amplitude');
