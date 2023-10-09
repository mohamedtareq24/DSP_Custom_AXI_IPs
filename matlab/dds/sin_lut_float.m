% Define the number of entries in the LUT
num_entries = 256;

% Calculate the step size for the angle
angle_step = 2*pi / num_entries;

% Initialize an empty array to store the sine values
sin_lut = zeros(1, num_entries);

% Generate the sine LUT
for i = 1:num_entries
    angle = (i - 1) * angle_step;
    sin_lut(i) = sin(angle);
end

% Plot the sine LUT
figure;
plot(sin_lut);
title('Sine Lookup Table');
xlabel('Index');
ylabel('sin(x)');
grid on;

% Optionally, you can save the LUT to a file
% save('sin_lut.mat', 'sin_lut');
