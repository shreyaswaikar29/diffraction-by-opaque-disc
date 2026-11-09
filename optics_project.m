%% Poisson spot: Fresnel diffraction by an opaque circular disc
clear; clc; close all;

%% Parameters
lambda = 632.8e-9;        % wavelength (He-Ne laser) [m]
k      = 2*pi/lambda;     % wave number
a      = 2e-3;            % disc radius [m]
z      = 2;               % disc-to-screen distance [m]
Rmax   = 6e-3;            % half-width of observation screen [m]

NF = a^2/(lambda*z);      % Fresnel number
fprintf('Fresnel number = %.2f\n', NF);

%% Radial integration (Babinet: free wave minus circular-hole wave)
rho = linspace(0, a, 4000);       % radial coordinate on the disc plane
r   = linspace(0, Rmax, 800);     % radial coordinate on the screen
U   = zeros(size(r));
%% Fresnel diffraction integral for a circular aperture:
% U_hole(r) = (2*pi*U0*exp(1i*k*z)/(1i*lambda*z)) * exp(1i*k*r^2/(2*z)) * integral_0^a exp(1i*k*rho^2/(2*z)) * besselj(0,k*r*rho/z) * rho drho
for n = 1:numel(r)
    integrand = exp(1i*k*rho.^2/(2*z)) .* besselj(0, k*r(n)*rho/z) .* rho;
    Ihole = trapz(rho, integrand);
    Uhole = (k/(1i*z)) * exp(1i*k*r(n)^2/(2*z)) * Ihole;
    U(n)  = 1-Uhole;            % normalised: U0*exp(ikz) = 1
end
I = abs(U).^2;                    % normalised intensity (I0 = 1)

fprintf('Centre intensity I/I0 = %.4f (theory = 1)\n', I(1));

%% 2D diffraction pattern (rotate radial profile)
N = 801;
x = linspace(-Rmax, Rmax, N);
[X, Y] = meshgrid(x, x);
Rr = sqrt(X.^2 + Y.^2);
I2D = interp1(r, I, Rr, 'spline', 0);

%% Plots
figure('Color','w','Position',[100 100 1200 450]);

subplot(1,3,1);
imagesc(x*1e3, x*1e3, I2D); axis image; colormap(hot);
colorbar; xlabel('x (mm)'); ylabel('y (mm)');
title('Diffraction pattern (Poisson spot at centre)');

subplot(1,3,2);
plot(r*1e3, I, 'b', 'LineWidth', 1.5); grid on; hold on;
yline(1, 'r--', 'I_0 (no disc)');
xlabel('Radial distance r (mm)'); ylabel('I / I_0');
title('Radial intensity profile');

subplot(1,3,3);
plot(-fliplr(r)*1e3, fliplr(I), 'b', r*1e3, I, 'b', 'LineWidth', 1.5);
hold on; yline(1,'r--'); grid on;
xlabel('x (mm)'); ylabel('I / I_0');
title('Cross-section through centre');

%% Bonus: on-axis intensity vs distance (always equals I0)
zv = linspace(0.5, 5, 200);
Iax = zeros(size(zv));
for m = 1:numel(zv)
    Iax(m) = abs(exp(1i*k*a^2/(2*zv(m))))^2;   % analytic result
end
figure('Color','w');
plot(zv, Iax, 'LineWidth', 1.8); ylim([0 1.5]); grid on;
xlabel('z (m)'); ylabel('On-axis I/I_0');
title('On-axis intensity behind an opaque disc');