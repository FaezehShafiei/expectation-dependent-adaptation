% ======================================================================
% Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.
% ======================================================================
% Fig. S17: GI and the distribution of block type and trial type.
%
%   A  block effect (BE) against the mean GI of GI-sorted windows of 300 trials (mean +/- SEM across neurons).
%      The line has the mean slope of the neurons.
%   B  trials per session in each condition for low-GI and high-GI trials (mean +/- SEM across sessions; grey
%      dots: single sessions within +/- 1 SD)
%   C  effect of block, trial type and their interaction on GI, in units of the within-session SD of GI (95% CI):
%      mixed model with a random intercept for session (black) and per-session estimates tested across sessions
%      (grey). Grey dots: single sessions within +/- 1 SD.
%
% Input:  figS17_data.mat
% Output: the figure window

clc; clear; close all;
load('figS17_data.mat');

c_low = [0.55 0.75 0.95];  c_high = [0.85 0.35 0.25];
c_dot = [0.9 0.9 0.9];                       % single sessions: solid light grey, so overlapping points do not get darker
figure('Color', 'w', 'Position', [50 50 1300 400]);
rng(1);                                      % same jitter every time

% A) block effect against the mean GI of the window (Part 0)
subplot(1,3,1); hold on;
xm = mean(GIw, 1, 'omitnan');  ym = mean(BEw, 1, 'omitnan');
ys = std(BEw, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(BEw), 1));
errorbar(xm, ym, ys, 'o', 'Color', [0.55 0.55 0.55], 'MarkerFaceColor', c_high, ...
    'MarkerEdgeColor', 'none', 'MarkerSize', 4, 'CapSize', 0);
xl = [min(xm) max(xm)];
plot(xl, mean(ym) + mean(slope_n) * (xl - mean(xm)), 'k', 'LineWidth', 2);   % mean slope through the mean of the points
yline(0, 'k:');
xlabel('Mean GI of the window'); ylabel('Block effect (BE)');
set(gca, 'TickDir', 'out', 'FontSize', 10); box off;
title({'A. Block effect over GI-sorted windows', ...
       sprintf('slope %.2f \\pm %.2f, signed-rank p %s (neurons); p %s (sessions)', mean(slope_n), ...
       std(slope_n)/sqrt(numel(slope_n)), fmt_p(p_slope_n), fmt_p(p_slope_s))}, 'FontWeight', 'normal', 'FontSize', 9);

% B) trials per session in each condition and GI group
subplot(1,3,2); hold on;
mL = mean(nLow, 1);  mH = mean(nHigh, 1);
sL = std(nLow, 0, 1) / sqrt(nS);  sH = std(nHigh, 0, 1) / sqrt(nS);
hb1 = bar((1:4) - 0.2, mL, 0.35, 'FaceColor', c_low,  'EdgeColor', 'none', 'BaseValue', 10);
hb2 = bar((1:4) + 0.2, mH, 0.35, 'FaceColor', c_high, 'EdgeColor', 'none', 'BaseValue', 10);
for c = 1:4                                   % one point per session, only sessions within +/- 1 SD of the mean of that condition and group
    inL = abs(nLow(:,c)  - mean(nLow(:,c)))  <= std(nLow(:,c));
    inH = abs(nHigh(:,c) - mean(nHigh(:,c))) <= std(nHigh(:,c));
    plot(c - 0.2 + 0.2*(rand(sum(inL),1) - 0.5), nLow(inL,c),  '.', 'Color', c_dot, 'MarkerSize', 8);
    plot(c + 0.2 + 0.2*(rand(sum(inH),1) - 0.5), nHigh(inH,c), '.', 'Color', c_dot, 'MarkerSize', 8);
end
errorbar((1:4) - 0.2, mL, sL, 'k', 'LineStyle', 'none');
errorbar((1:4) + 0.2, mH, sH, 'k', 'LineStyle', 'none');
set(gca, 'XTick', 1:4, 'XTickLabel', cond_names, 'XTickLabelRotation', 30, 'TickDir', 'out', 'FontSize', 10); box off;
ylim([10 130]);  
xlabel('grey dots: sessions within \pm1 SD', 'FontSize', 9);
ylabel('Trials per session'); legend([hb1 hb2], {'low GI', 'high GI'}, 'Location', 'north', 'Orientation', 'horizontal'); legend boxoff;
title('B. Trials per condition and GI group', 'FontWeight', 'normal');

% C) GI predicted by block, trial type and their interaction (Part 1c)
subplot(1,3,3); hold on;
nmC = {'blk', 'trl', 'blk:trl'};  lblC = {'Block', 'Trial type', 'Block x trial type'};
iC = cellfun(@(t) find(strcmp(cg.Name, t)), nmC);
est = cg.Estimate(iC) / sdGI;  lo = cg.Lower(iC) / sdGI;  up = cg.Upper(iC) / sdGI;   % mixed model, in SD of GI
est = est(:);  lo = lo(:);  up = up(:);
mS  = mean(bG, 1)' / sdGI;                                                           % per session
ciS = tinv(0.975, nS - 1) * std(bG, 0, 1)' / sqrt(nS) / sdGI;
yC = (1:3)';
pts = bG / sdGI;                                                                      % one value per session and term
for k = 1:3                                   % sessions within +/- 1 SD of the per-session values of that term, on the line of the per-session estimate
    in = abs(pts(:,k) - mean(pts(:,k))) <= std(pts(:,k));
    plot(pts(in,k), yC(k) + 0.3 + 0.2*(rand(sum(in),1) - 0.5), '.', 'Color', c_dot, 'MarkerSize', 8);
end
h1 = errorbar(est, yC - 0.3, [], [], est - lo, up - est, 'ko', 'MarkerFaceColor', 'k', 'LineWidth', 1.2);                % mixed model
h2 = errorbar(mS,  yC + 0.3, [], [], ciS, ciS, 'o', 'Color', [0.5 0.5 0.5], 'MarkerFaceColor', 'w', 'LineWidth', 1.2);   % per session
xline(0, 'k:');
px = [min(mean(pts,1) - std(pts,0,1)), max(mean(pts,1) + std(pts,0,1))];             % range of the plotted sessions (mean +/- 1 SD)
x0 = min([lo; mS - ciS; px(1)]);  x1 = max([up; mS + ciS; px(2)]);  w = x1 - x0;
xlim([x0 - 0.1*w, x1 + 1.0*w]);
for k = 1:3
    text(x1 + 0.1*w, yC(k), sprintf('mixed p %s\nsessions p %s', fmt_p(cg.pValue(iC(k))), fmt_p(signrank(bG(:,k)))), ...
        'FontSize', 8, 'VerticalAlignment', 'middle');
end
set(gca, 'YTick', yC, 'YTickLabel', lblC, 'YDir', 'reverse', 'TickDir', 'out', 'FontSize', 10); box off;
ylim([0.4 3.6]);
xlabel({'Effect on GI (within-session SD of GI, 95% CI)', 'grey dots: single sessions within \pm1 SD'});
legend([h1 h2], {'mixed model (session intercept)', 'per session, across sessions'}, 'Location', 'southoutside', 'Box', 'off', 'FontSize', 8);
title('C. GI predicted by block and trial type', 'FontWeight', 'normal');

%% ======================================================================
% Local functions

function s = fmt_p(p)
if p < 0.001, s = '< 0.001'; else, s = sprintf('= %.3f', p); end
end