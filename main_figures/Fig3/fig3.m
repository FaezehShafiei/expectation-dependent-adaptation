% ======================================================================
% Fig3. Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.

% ======================================================================

% Figure 3: repetition suppression and the block effect in IT.

%
%   A  Population PSTHs of the four conditions, with an inset showing the
%      adaptation index (AI) for repeated (RT) and alternated (AT) trials,
%      collapsed across blocks
%   B  AI per condition, stimulus-specific adaptation (SSA) per block and
%      block effect (BE), full window (0-200 ms after response onset)
%   C  The same for the early window (0-100 ms)
%   D  The same for the late window (100-200 ms)
%   In B-D each panel has a narrow panel beside it with the single-neuron values (dots) on their own y-axis
%
% Points and bars show the mean across neurons; error bars are the SEM.
% Response windows start at the response onset.
%
% Input:  fig3_data.mat (variables PSTH_pop, n_neurons, AI_repeated, AI_alternated, p_repeated,
%         p_alternated, and AIs, SSA_RB, SSA_AB, BE, p_SSA, p_BE for the full, early and late windows)
% Output: the figure window

clc; clear; close all;
load('fig3_data.mat');

%% Colours and labels
col.RB_rep = [0.80 0.10 0.10];
col.RB_alt = [0.95 0.55 0.15];
col.AB_rep = [0.10 0.35 0.95];
col.AB_alt = [0.40 0.70 1.00];
colors = [col.RB_rep; col.RB_alt; col.AB_rep; col.AB_alt];
AI_labels = {'RB-Rep', 'RB-Alt', 'AB-Rep', 'AB-Alt'};
S1_ON = 250;                                 % S1 onset (ms from trial start)

figure('Color', 'w', 'Position', [50 50 1300 1400]);

%% Panel A: population PSTHs (top row, all three columns)
axBig = subplot(4, 3, [1 2 3]);  hold on;
mRB_rep = PSTH_pop.RB_rep;  mRB_alt = PSTH_pop.RB_alt;
mAB_rep = PSTH_pop.AB_rep;  mAB_alt = PSTH_pop.AB_alt;
t_ms = (0:numel(mRB_rep) - 1) - S1_ON;
plot(t_ms, mRB_rep, 'Color', col.RB_rep, 'LineWidth', 2);
plot(t_ms, mRB_alt, 'Color', col.RB_alt, 'LineWidth', 2);
plot(t_ms, mAB_rep, 'Color', col.AB_rep, 'LineWidth', 2);
plot(t_ms, mAB_alt, 'Color', col.AB_alt, 'LineWidth', 2);
xline(0, ':k');  xline(100, ':k');  xline(400, ':k');  xline(500, ':k');
xlabel('Time from S1 onset (ms)');  ylabel('Firing rate (Hz)');
title(sprintf('A. Population PSTHs (n = %d)', n_neurons));
legend({'RB-Rep', 'RB-Alt', 'AB-Rep', 'AB-Alt'}, 'Location', 'northeast');  legend boxoff;
xlim([-100 800]);  box off;  set(gca, 'TickDir', 'out', 'FontSize', 11);

% Inset: AI for repeated vs alternated trials (collapsed across blocks)
axPos = get(axBig, 'Position');
axInset = axes('Position', [axPos(1) + axPos(3) * 0.72, axPos(2) + axPos(4) * 0.55, axPos(3) * 0.20, axPos(4) * 0.35]);
hold(axInset, 'on');
ins_colors = [0.80 0.10 0.10; 0.10 0.35 0.95];
AI_ins_means = [nanmean(AI_repeated), nanmean(AI_alternated)];
AI_ins_sems  = [nanstd(AI_repeated) / sqrt(numel(AI_repeated)), nanstd(AI_alternated) / sqrt(numel(AI_alternated))];
bar(1:2, AI_ins_means, 'FaceColor', 'flat', 'CData', ins_colors);
% single-neuron AI values as dots (jittered horizontally)
AI_dots = {AI_repeated(isfinite(AI_repeated)), AI_alternated(isfinite(AI_alternated))};
for k = 1:2
    graded_dots(axInset, k, AI_dots{k}, mean(AI_dots{k}));
end
errorbar(1:2, AI_ins_means, AI_ins_sems, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
% fixed y-range (neurons outside it are not shown)
ylim(axInset, [-0.1 0.1]);
if p_repeated < 0.01
    text(1, 0.085, '***', 'FontSize', 12, 'HorizontalAlignment', 'center');
end
if p_alternated < 0.01
    text(2, 0.085, '***', 'FontSize', 12, 'HorizontalAlignment', 'center');
end
set(axInset, 'XTick', 1:2, 'XTickLabel', {'RT', 'AT'}, 'FontSize', 7);
ylabel(axInset, 'AI', 'FontSize', 7);
yline(axInset, 0, 'k:');
box(axInset, 'off');  set(axInset, 'TickDir', 'out');

%% Panels B, C, D: AI, SSA and block effect for the three windows
window_data = { ...
    struct('AIs', AIs_full,  'SSA_RB', SSA_RB_full,  'SSA_AB', SSA_AB_full,  'BE', BE_full,  'p_SSA', p_SSA_full,  'p_BE', p_BE_full,  'label', 'B. Full window (0-200 ms)'), ...
    struct('AIs', AIs_early, 'SSA_RB', SSA_RB_early, 'SSA_AB', SSA_AB_early, 'BE', BE_early, 'p_SSA', p_SSA_early, 'p_BE', p_BE_early, 'label', 'C. Early window (0-100 ms)'), ...
    struct('AIs', AIs_late,  'SSA_RB', SSA_RB_late,  'SSA_AB', SSA_AB_late,  'BE', BE_late,  'p_SSA', p_SSA_late,  'p_BE', p_BE_late,  'label', 'D. Late window (100-200 ms)') ...
};

for row = 1:3
    d = window_data{row};
    base = 3 + (row - 1) * 3;                % subplot index before this row's panels

    % AI per condition
    ax = subplot(4, 3, base + 1);  hold on;
    means = nanmean(d.AIs, 1);
    sems  = nanstd(d.AIs, [], 1) ./ sqrt(sum(~isnan(d.AIs), 1));
    errorbar(1:4, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    for i = 1:4
        plot(i, means(i), 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    end
    xlim([0.5 4.5]);  ylim([-0.05 0.1]);  set(gca, 'XTick', 1:4, 'XTickLabel', AI_labels);
    ylabel('AI');  yline(0, 'k:');  box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
    dot_inset(ax, {d.AIs(:, 1), d.AIs(:, 2), d.AIs(:, 3), d.AIs(:, 4)}, means, [0.5 4.5], d.label, AI_labels);

    % Stimulus-specific adaptation in each block
    ax = subplot(4, 3, base + 2);  hold on;
    meanSSA = [nanmean(d.SSA_RB), nanmean(d.SSA_AB)];
    semSSA  = [nanstd(d.SSA_RB) / sqrt(sum(~isnan(d.SSA_RB))), nanstd(d.SSA_AB) / sqrt(sum(~isnan(d.SSA_AB)))];
    errorbar([1 2], meanSSA, semSSA, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    plot([1 2], meanSSA, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    xlim([0.5 2.5]);  ylim([-0.05 0.1]);  set(gca, 'XTick', [1 2], 'XTickLabel', {'RB', 'AB'});
    ylabel('SSA');  yline(0, 'k:');  box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
    dot_inset(ax, {d.SSA_RB, d.SSA_AB}, meanSSA, [0.5 2.5], sprintf('SSA (p=%.3g)', d.p_SSA), {'RB', 'AB'});

    % Block effect
    ax = subplot(4, 3, base + 3);  hold on;
    meanBE = nanmean(d.BE);  semBE = nanstd(d.BE) / sqrt(sum(~isnan(d.BE)));
    errorbar(1, meanBE, semBE, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    plot(1, meanBE, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    xlim([0.5 1.5]);  ylim([-0.05 0.1]);  set(gca, 'XTick', 1, 'XTickLabel', {'RB - AB'});
    ylabel('Block effect');  yline(0, 'k:');  box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
    dot_inset(ax, {d.BE}, meanBE, [0.5 1.5], sprintf('BE (p=%.3g)', d.p_BE), {'RB-AB'});
end

%% ======================================================================
% Local functions

function graded_dots(ax, x0, v, mu)
% Single-neuron values as tiny opaque dots at position x0 (jittered horizontally). Dots do not blend
% (no transparency). The grey level depends on the rank of each neuron's distance from the mean mu divided by the
% number of neurons (t: 0 = closest, 1 = farthest), on a logarithmic scale: g = log10(1 + 9 t) runs from 0 (black)
% to 1 (white); it rises quickly near the mean and flattens towards the far neurons. The dot size follows the same
% grading (larger close to the mean, smaller far from it).
v = v(isfinite(v));
n = numel(v);
[~, ord] = sort(abs(v - mu), 'ascend');                % closest first
v = v(ord);
t = (0:n - 1)' / max(n - 1, 1);                        % rank / number, 0 ... 1
g = log10(1 + 9 * t);                                  % logarithmic grading, black -> white
v = flipud(v);  g = flipud(g);                         % draw far (light) dots first, near (dark) dots on top
jit = (rand(n, 1) - 0.5) * 0.6;
sz = 1 + 4 * (1 - g);                                  % dot size graded the same way: 5 (closest) ... 1 (farthest)
scatter(ax, x0 + jit, v, sz, [g g g], 'filled', 'MarkerEdgeColor', 'none');
end

function dot_inset(ax, vals, means, xl, ttl, xt)
% The main axes keep the left part of their cell; a narrow panel beside them (to the right) shows every neuron as a
% tiny opaque dot on its own y-axis (-0.2 to 0.2), with the mean marked by a short red bar.
% vals: cell of column vectors (one per x position 1..numel(vals)); means: their means.
p = get(ax, 'Position');
set(ax, 'Position', [p(1), p(2), p(3) * 0.58, p(4)]);
title(ax, ttl, 'FontSize', 9);
unit = 0.075 * p(3);                                   % width of one column: the same in every side panel
axI = axes('Position', [p(1) + p(3) * 0.66, p(2), numel(vals) * unit, p(4)]);   % 4, 2 or 1 columns wide
hold(axI, 'on');
allv = [];
for k = 1:numel(vals)
    v = vals{k};  allv = [allv; v(isfinite(v))];
end
for k = 1:numel(vals)
    graded_dots(axI, k, vals{k}, means(k));
    plot(axI, k + [-0.3 0.3], [means(k) means(k)], 'r', 'LineWidth', 1.5);
end
xlim(axI, xl);  ylim(axI, [-0.2 0.2]);                    % fixed range; neurons outside it are not shown
yline(axI, 0, 'k:');
set(axI, 'XTick', 1:numel(vals), 'XTickLabel', xt, 'XTickLabelRotation', 45, 'FontSize', 6, 'TickDir', 'out', 'Box', 'off');
title(axI, 'Single neurons', 'FontSize', 8);
end