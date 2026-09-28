%% McCabe-Thiele Distillation Column Design: Benzene-Toluene
clc; clear; close all;

%% Design specifications
alpha = 2.5;     % relative volatility of benzene to toluene
xF = 0.5;        % feed composition (mole fraction benzene)
xD = 0.95;       % top product (distillate) composition
xB = 0.05;       % bottom product composition

%% Equilibrium curve
x = 0:0.01:1;
y_eq = alpha*x ./ (1 + (alpha-1)*x);

%% Minimum reflux ratio (feed is saturated liquid, so the q-line is vertical at x = xF)
y_star = alpha*xF / (1 + (alpha-1)*xF);   % equilibrium y at the feed composition
Rmin = (xD - y_star) / (y_star - xF);
R = 1.5 * Rmin;                            % actual reflux ratio
fprintf('Minimum reflux ratio Rmin = %.2f\n', Rmin);
fprintf('Actual reflux ratio R = %.2f\n', R);

%% Operating lines
% Rectifying line: y = R/(R+1)*x + xD/(R+1)
y_rect = R/(R+1) * x + xD/(R+1);

% Point where the rectifying line meets the feed line (x = xF)
y_int = R/(R+1) * xF + xD/(R+1);

% Stripping line: passes through (xB, xB) and (xF, y_int)
slope_s = (y_int - xB) / (xF - xB);
y_strip = xB + slope_s * (x - xB);

%% Plot
figure;
plot(x, y_eq, 'b', 'LineWidth', 1.5); hold on;
plot([0 1], [0 1], 'k--');                       % 45 degree line
plot(x(x >= xF), y_rect(x >= xF), 'r', 'LineWidth', 1.5);      % rectifying line
plot(x(x <= xF), y_strip(x <= xF), 'g', 'LineWidth', 1.5);     % stripping line
plot([xF xF], [xF y_int], 'm', 'LineWidth', 1.5);              % feed line
xlabel('x (liquid mole fraction of benzene)');
ylabel('y (vapour mole fraction of benzene)');
title('McCabe-Thiele Diagram: Benzene-Toluene');
legend('Equilibrium curve', 'y = x line', 'Rectifying line', 'Stripping line', 'Feed line', 'Location', 'southeast');
axis([0 1 0 1]);
axis square;
grid on;
%% Step off stages (start at the top product, move toward the bottom product)
xp = xD; yp = xD;            % start on the 45 degree line at xD
stairX = xD; stairY = xD;
stages = 0;
feedStage = 0;

while xp > xB && stages < 50
    % horizontal move to the equilibrium curve
    xnew = yp / (alpha - (alpha-1)*yp);
    stages = stages + 1;
    stairX(end+1) = xnew; stairY(end+1) = yp;

    % note the first stage that crosses the feed composition
    if feedStage == 0 && xnew <= xF
        feedStage = stages;
    end

    % vertical move to the operating line
    if xnew > xF
        ynew = R/(R+1)*xnew + xD/(R+1);       % rectifying line
    else
        ynew = xB + slope_s*(xnew - xB);      % stripping line
    end
    stairX(end+1) = xnew; stairY(end+1) = ynew;

    xp = xnew; yp = ynew;
end

plot(stairX, stairY, 'k', 'LineWidth', 1);
legend('Equilibrium curve', 'y = x line', 'Rectifying line', 'Stripping line', 'Feed line', 'Stages', 'Location', 'southeast');

fprintf('Number of theoretical stages = %d\n', stages);
fprintf('Optimum feed stage = %d\n', feedStage);
saveas(gcf, 'mccabe_thiele.png');

%% Effect of reflux ratio on number of stages
multipliers = [1.2 1.5 2 3];     % R as a multiple of Rmin
fprintf('\nR/Rmin    R      Stages\n');
for i = 1:numel(multipliers)
    Ri = multipliers(i) * Rmin;
    n = count_stages(Ri, alpha, xF, xD, xB);
    fprintf('%.1f      %.2f    %d\n', multipliers(i), Ri, n);
end

%% Local function (keep it at the end of the file)
function n = count_stages(R, alpha, xF, xD, xB)
y_int = R/(R+1)*xF + xD/(R+1);
slope_s = (y_int - xB) / (xF - xB);
xp = xD; yp = xD; n = 0;
while xp > xB && n < 50
    xnew = yp / (alpha - (alpha-1)*yp);
    n = n + 1;
    if xnew > xF
        ynew = R/(R+1)*xnew + xD/(R+1);
    else
        ynew = xB + slope_s*(xnew - xB);
    end
    xp = xnew; yp = ynew;
end
end