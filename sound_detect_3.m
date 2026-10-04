clc;
clear;

Fs = 8000;
N = 650;
t = (0:N-1)/Fs;

%% Drone
f_drone = 300;
drone = 0.8 * sin(2*pi*f_drone*t);

%% Noise
noise = zeros(1,N);
for k = 1:14
    noise = noise + 0.3*sin(2*pi*randi([100 2000])*t) + 0.2*randn(1,N);
end

mixed = drone + noise;
mixed = mixed / max(abs(mixed));

%% ADC (8-bit)
x = int8(mixed * 127);

%% FIR
h = [8 16 24 32 40 48 56 64];

F_scaling = 9;

y = zeros(1,N);

for n = 8:N
    sum_val = 0;
    for k = 1:8
        sum_val = sum_val + h(k) * double(x(n-k+1));
    end
    
    y(n) = floor(sum_val / (2^F_scaling));
    
    if y(n) > 127
        y(n) = 127;
    elseif y(n) < -128
        y(n) = -128;
    end
end

%% Energy
E_scaling = 8;

E = [];
idx = 1;

for i = 1:8:length(y)-7
    energy = 0;
    
    for k = 0:7
        val = y(i+k);
        energy = energy + val*val;
    end
    
    E(idx) = floor(energy / (2^E_scaling));
    idx = idx + 1;
end

%% Print values
disp('Energy Range:');
disp([min(E) max(E)]);

%% Thresholds
Drone_Energy_min = floor(min(E) * 0.8);
Drone_Energy_max = ceil(max(E) * 1.2);

disp('-------------------');
disp(['F_scaling = ' num2str(F_scaling)]);
disp(['E_scaling = ' num2str(E_scaling)]);
disp(['Drone_Energy_min = ' num2str(Drone_Energy_min)]);
disp(['Drone_Energy_max = ' num2str(Drone_Energy_max)]);

%% Plot
figure;
plot(E);
title('Final Energy (After Correct Scaling)');
grid on;