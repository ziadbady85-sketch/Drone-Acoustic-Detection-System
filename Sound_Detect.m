clc;
clear;


Fs = 8000;
N = 650;  

t = (0:N-1)/Fs;


f_drone = 300;  
drone = 0.8 * sin(2*pi*f_drone*t);

signals = zeros(14, N);

for k = 1:14
    rand_freq = randi([100 2000]);   
    rand_amp  = rand * 0.5;          
    
    signals(k,:) = rand_amp * sin(2*pi*rand_freq*t) ...
                   + 0.2*randn(1,N); % noise
end

mixed = drone;

for k = 1:14
    mixed = mixed + signals(k,:);
end

mixed = mixed / max(abs(mixed));

audio_8bit = int8(mixed * 127);

fileID = fopen('samples_bin.txt','w');

for i = 1:N
    val = typecast(audio_8bit(i), 'uint8');
    binStr = dec2bin(val,8);
    fprintf(fileID, '%s\n', binStr);
end

fclose(fileID);

disp('Binary file saved');

figure;
plot(audio_8bit);
title('Mixed Signal (Drone + Noise)');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;