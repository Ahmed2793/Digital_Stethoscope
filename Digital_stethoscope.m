% Check if a serialport object exists and close it
if exist('s', 'var') && isvalid(s)
    fclose(s);
    delete(s);
    clear s;
end

% Create a new serialport object and specify the COM port
s = serialport('COM9', 115200);

% Open the serial connection
configureTerminator(s, "LF");
fopen(s);

figure;

% Number of data points to display
numPoints = 100;

% Initialize data vectors
rawData = zeros(1, numPoints);
filteredData = zeros(1, numPoints);
time = zeros(1, numPoints);

% Create the time-domain plot for Raw signal
subplot(2, 2, 1);
hRawPlot = plot(time, rawData, 'b', 'LineWidth', 1.5);
title('Raw Signal Plot');
xlabel('Time');
ylabel('Analog Reading');

% Set up the plot limits
xlim([0, numPoints]);
ylim([-20, 50]); % Adjust based on your analog readings range

% Create the spectrum plot for Raw signal
subplot(2, 2, 2);
hRawSpectrumPlot = plot(0, 0);
title('Raw Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

% Set up the plot limits
xlim([0, 10]); % Adjust the frequency range as needed

% Create the time-domain plot for Filtered signal
subplot(2, 2, 3);
hFilteredPlot = plot(time, filteredData, 'r', 'LineWidth', 1.5);
title('Filtered Signal Plot');
xlabel('Time');
ylabel('Analog Reading');

% Set up the plot limits
xlim([0, numPoints]);
ylim([-20, 50]); % Adjust based on your analog readings range

% Create the spectrum plot for Filtered signal
subplot(2, 2, 4);
hFilteredSpectrumPlot = plot(0, 0);
title('Filtered Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

% Set up the plot limits
xlim([0, 10]); % Adjust the frequency range as needed

% Main loop for reading and plotting data
while ishandle(hRawPlot)
    % Read data from the Arduino
    newData = str2double(fgetl(s));

    % Update the data vectors
    rawData = [rawData(2:end), newData];
    time = 1:numPoints;

    % Filter the raw signal (you can customize the filter as needed)
    % For simplicity, a simple moving average is used as a low-pass filter
    filterOrder = 5;
    filteredData = [filteredData(2:end), mean(rawData(end - filterOrder + 1:end))];

    % Update the Raw signal and filtered signal time-domain plots
    set(hRawPlot, 'XData', time, 'YData', rawData);
    set(hFilteredPlot, 'XData', time, 'YData', filteredData);

    % Compute and update the Raw signal frequency spectrum
    spectrumRaw = fft(rawData);
    frequencyRaw = linspace(0, 1, numPoints) * (1 / (2 * (1 / 115200))); % Adjust for your sampling rate
    set(hRawSpectrumPlot, 'XData', frequencyRaw, 'YData', abs(spectrumRaw));

    % Compute and update the Filtered signal frequency spectrum
    spectrumFiltered = fft(filteredData);
    frequencyFiltered = linspace(0, 1, numPoints) * (1 / (2 * (1 / 115200))); % Adjust for your sampling rate
    set(hFilteredSpectrumPlot, 'XData', frequencyFiltered, 'YData', abs(spectrumFiltered));

    drawnow;

    pause(0.001);  % Adjust the pause duration as needed
end

% Close the serial connection when done
fclose(s);
delete(s);
clear s;