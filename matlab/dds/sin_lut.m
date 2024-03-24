clc;
clear;

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

%Create a file for writing
fileID = fopen('D:\Digital_Electronics\DSP\DSP_course\rtl\dds\sin_lut_init_file.txt', 'w');

%Write the sine LUT values in hexadecimal format, spaced by newline characters
for i = 1:num_entries
    fprintf(fileID, '%s\n', bin((sin_lut_fixed(i))));
end

fclose(fileID);

%Plot the sine LUT in fixed-point format
figure;
plot(sin_lut_fixed);
title('Sine Lookup Table (Signed 16.8 Fixed-Point)');
xlabel('Index');
ylabel('sin(x)');
grid on;
