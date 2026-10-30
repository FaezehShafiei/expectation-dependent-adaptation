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
%  Fig. S13: expectation-dependent repetition effects in vlPFC
% single units and field potentials (the vlPFC version of Fig. 4).
% It also needs ndass_confid_niceplot.m and
% ndass_smooth.m on the MATLAB path.
%
%   A  Single units: Cohen's d among expected vs unexpected trials, one dot
%      per neuron, with the regression line and the correlation
%   B  Single units: Cohen's d for expected, neutral and unexpected trials,
%      for repetition-suppressed (blue, positive d on expected trials) and
%      repetition-enhanced (red, negative d) neurons
%   C  Single units: time course of the correlation from A (relative to
%      the onset of the second stimulus), with an inset comparing baseline
%      and response windows
%   D  Field potentials: as A
%   E  Field potentials: as B
%   F  Field potentials: as C
%
% Points in B and E show single neurons or sites (transparent) and the
% mean across them, with SEM error bars. Brackets mark paired t-tests
% between expected and neutral and between neutral and unexpected trials,
% separately for each group (* p < 0.05, ** p < 0.01, *** p < 0.001,
% n.s. = not significant). The grey band in C and F marks the 0-100 ms
% response window.
%
% Input:  figS13_data.mat
% Output: the figure window

clc; clear; close all;
load('figS13_data.mat');

ITC_c = [0, 0.5020, 0];                      % green
labels = {'Expected', 'Neutral', 'Unexpected'};

figure('Color', 'w', 'Position', [50 50 1400 800]);
sgtitle('vlPFC single units (A-C) and LFP (D-F)', 'FontWeight', 'normal');

%% A: single units, expected vs unexpected
subplot(2, 3, 1);  hold on;
x = cohen_d_rep_it';
y = cohen_d_alt_it';

scatter(x, y, 10, 'o', 'MarkerFaceColor', [0.2 0.6 0.8], 'MarkerEdgeColor', 'none');

p = polyfit(x, y, 1);
xfit = linspace(min(x), max(x), 100);
plot(xfit, polyval(p, xfit), 'r-', 'LineWidth', 2);

[r_a, pval_a] = corr(x, y);
text(min(x), max(y), sprintf('r = %.2f, %s', r_a, p_str(pval_a)), ...
    'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'top');

xlabel('Cohen''s d among Expected trials');
ylabel('Cohen''s d among Unexpected trials');
axis square;  set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 12, 'LineWidth', 1);

%% B: single units, expected / neutral / unexpected
subplot(2, 3, 2);  hold on;
pos = cohen_d_rep_it > 0;                    % neurons with a positive effect on expected trials
neg = cohen_d_rep_it < 0;

data_pos = {cohen_d_rep_it(pos), cohen_d_rnd_it(pos), cohen_d_alt_it(pos)};
data_neg = {cohen_d_rep_it(neg), cohen_d_rnd_it(neg), cohen_d_alt_it(neg)};
for k = 1:3
    draw_group(k + 0.1, data_pos{k}, [0 0 1]);
    draw_group(k - 0.1, data_neg{k}, [1 0 0]);
end
draw_brackets(data_pos, data_neg);
text(0.5, 1.12, 'Repetition suppressed neurons', 'Units', 'normalized', 'Color', [0 0 1], 'HorizontalAlignment', 'center', 'FontSize', 9);
text(0.5, 1.04, 'Repetition enhanced neurons', 'Units', 'normalized', 'Color', [1 0 0], 'HorizontalAlignment', 'center', 'FontSize', 9);

axis square;  xlim([0.5 3.5]);
set(gca, 'XTick', 1:3, 'XTickLabel', labels, 'FontName', 'Arial', 'FontSize', 7, ...
    'LineWidth', 0.5, 'TickDir', 'out', 'Box', 'off');
ylabel('Cohen''s d', 'FontWeight', 'bold', 'FontSize', 8);

%% C: single units, time course and baseline vs response
subplot(2, 3, 3);  hold on;
ndass_confid_niceplot(r_boot_spike, time_spike, 5, ITC_c, 0.3);
ylabel('Correlation coefficient');
xlabel('Time from 2nd stim. onset (ms)');
xlim([-50 400]);
plot([0 0], ylim, 'k', 'LineWidth', 1);
yl = ylim;
fill([0 100 100 0], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
set(gca, 'Box', 'off', 'TickDir', 'out');

axes('Position', [0.70 0.80 0.10 0.10]);  hold on;
means = [nanmean(r_base_spike), nanmean(r_resp_spike)];
sems  = [nanstd(r_base_spike),  nanstd(r_resp_spike)];
bar(1:2, means);
errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
set(gca, 'XTick', 1:2, 'XTickLabel', {'Baseline', 'Response'}, 'FontSize', 6);
title(p_str(p_baseresp_spike), 'FontSize', 6);

%% D: field potentials, expected vs unexpected
subplot(2, 3, 4);  hold on;
x = cohen_d_rep_it_lfp_static;
y = cohen_d_alt_it_lfp_static;

scatter(x, y, 10, 'o', 'MarkerFaceColor', [0.2 0.6 0.8], 'MarkerEdgeColor', 'none');

p = polyfit(x, y, 1);
xfit = linspace(min(x), max(x), 100);
plot(xfit, polyval(p, xfit), 'r-', 'LineWidth', 2);

[r_d, pval_d] = corr(x, y);
text(min(x), max(y), sprintf('r = %.2f, %s', r_d, p_str(pval_d)), ...
    'FontSize', 12, 'FontWeight', 'bold', 'VerticalAlignment', 'top');

xlabel('Repetition effect among Expected trials');
ylabel('Repetition effect among Unexpected trials');
axis square;  set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 12, 'LineWidth', 1);

%% E: field potentials, expected / neutral / unexpected
subplot(2, 3, 5);  hold on;
x = cohen_d_rep_it_lfp_static;               % expected
y = cohen_d_alt_it_lfp_static;               % unexpected
z = cohen_d_rnd_it_lfp_static;               % neutral

data_pos = {x(x > 0), z(x > 0), y(x > 0)};
data_neg = {x(x < 0), z(x < 0), y(x < 0)};
for k = 1:3
    draw_group(k + 0.1, data_pos{k}, [0 0 1]);
    draw_group(k - 0.1, data_neg{k}, [1 0 0]);
end
draw_brackets(data_pos, data_neg);

axis square;  xlim([0.5 3.5]);
set(gca, 'XTick', 1:3, 'XTickLabel', labels, 'FontName', 'Arial', 'FontSize', 7, ...
    'LineWidth', 0.5, 'TickDir', 'out', 'Box', 'off');
ylabel('Cohen''s d', 'FontWeight', 'bold', 'FontSize', 8);

%% F: field potentials, time course and baseline vs response
subplot(2, 3, 6);  hold on;
ndass_confid_niceplot(r_boot_lfp, time_lfp, 20, ITC_c, 0.3);
ylabel('Correlation coefficient');
xlabel('Time from 2nd stim. onset (ms)');
xlim([-50 400]);
ylim([-0.5 -0.2]);
plot([0 0], ylim, 'k', 'LineWidth', 1);
yl = ylim;
fill([0 100 100 0], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
set(gca, 'Box', 'off', 'TickDir', 'out');

axes('Position', [0.70 0.32 0.10 0.10]);  hold on;
means = [nanmean(r_base_lfp), nanmean(r_resp_lfp)];
sems  = [nanstd(r_base_lfp),  nanstd(r_resp_lfp)];
bar(1:2, means);
errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
set(gca, 'XTick', 1:2, 'XTickLabel', {'Baseline', 'Response'}, 'FontSize', 6);
title(p_str(p_baseresp_lfp), 'FontSize', 6);

%% ======================================================================
% Local functions

function draw_group(xk, v, col)
% Single values (transparent dots), their mean and SEM at position xk.
scatter(xk * ones(size(v)), v, 6, 'MarkerFaceColor', col, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.25);
m  = mean(v);
se = std(v) / sqrt(numel(v));
errorbar(xk, m, se, 'k', 'LineWidth', 1, 'CapSize', 6);
scatter(xk, m, 25, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
end

function draw_brackets(data_pos, data_neg)
% Paired t-tests between neighbouring conditions, drawn as brackets in the
% colour of the group (blue: positive on expected trials, red: negative).
% Each cell holds expected, neutral and unexpected, from the same neurons.
yl = ylim;  rng = diff(yl);
tick = 0.03 * rng;
ylim([yl(1) - 0.30 * rng, yl(2) + 0.30 * rng]);
top = yl(2);  bot = yl(1);

bracket(1.1, 2.1, top + 0.15 * rng, +1, data_pos{1}, data_pos{2}, [0 0 1], tick);   % blue, expected vs neutral
bracket(2.1, 3.1, bot - 0.05 * rng, -1, data_pos{2}, data_pos{3}, [0 0 1], tick);   % blue, neutral vs unexpected
bracket(1.9, 2.9, top + 0.05 * rng, +1, data_neg{2}, data_neg{3}, [1 0 0], tick);   % red, neutral vs unexpected
bracket(0.9, 1.9, bot - 0.15 * rng, -1, data_neg{1}, data_neg{2}, [1 0 0], tick);   % red, expected vs neutral
end

function bracket(x1, x2, y, dir, a, b, col, tick)
% One bracket between x1 and x2 at height y (dir = +1 above the data, -1
% below it) with the paired t-test result between a and b as stars.
[~, p] = ttest(a, b);
line([x1 x1 x2 x2], [y - dir * tick, y, y, y - dir * tick], 'Color', col, 'LineWidth', 0.75);
text(mean([x1 x2]), y, stars_of(p), 'Color', col, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 9);
end

function s = stars_of(p)
% Significance label for a p-value (n.s. if p >= 0.05).
if p < 0.001, s = '***';
elseif p < 0.01, s = '**';
elseif p < 0.05, s = '*';
else, s = 'n.s.';
end
end

function s = p_str(p)
% p-value as text. Never printed as p = 0: for bootstrap p-values the
% smallest possible value is 1/n_boot, which is also shown as p < 0.001.
if p <= 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end