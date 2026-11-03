% ======================================================================
% Fig5. Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.

% ======================================================================

% Figure 5: the block effect in IT neurons with low and high GI.

%
%   A  Population PSTHs of the four conditions, low-GI neurons
%   B  Low-GI neurons: AI per condition, stimulus-specific adaptation
%      (SSA) per block and block effect (BE)
%   C  Population PSTHs, high-GI neurons
%   D  High-GI neurons: AI, SSA and BE as in B
%   E  BE of low- vs high-GI neurons, vlPFC to IT direction, early window
%   F  The same for the reverse direction, IT to vlPFC
%   G  The same for the baseline window
%
% Points show the mean across neurons; error bars are the SEM. In B, D and E-G a
% narrow panel beside each plot shows every neuron as a tiny dot (grey level and
% size graded by the rank of the distance from the mean divided by the number of
% neurons, logarithmic; red bar = mean). E-G are bars with the same
% dot panel beside them..
%
% Input:  fig5_data.mat (variables PSTH_poplgi, PSTH_pophgi, AIs_lgi, AIs_hgi,
%         BE_lgi, BE_hgi, p_SSA_lgi, p_SSA_hgi, p_BE_lgi, p_BE_hgi,
%         BE_lgi_rev, BE_hgi_rev, BE_lgi_base, BE_hgi_base,
%         p_early, p_rev, p_base)
% Output: the figure window

clc; clear; close all;
load('fig5_data.mat');

%% Colours and settings
col.RB_rep = [0.80 0.10 0.10];
col.RB_alt = [0.95 0.55 0.15];
col.AB_rep = [0.10 0.35 0.95];
col.AB_alt = [0.40 0.70 1.00];
colors = [col.RB_rep; col.RB_alt; col.AB_rep; col.AB_alt];
AI_labels = {'RB-Rep', 'RB-Alt', 'AB-Rep', 'AB-Alt'};
S1_ON = 250;                                 % S1 onset (ms from trial start)
dot_ylim = [-0.5 0.5];                       % y-range of the single-neuron panels beside B and D (values outside are not shown)

figure('Color', 'w', 'Position', [50 50 1600 1100]);

%% A, B: low-GI neurons (top row)
psth_panel(subplot(3, 4, 1), PSTH_poplgi, col, S1_ON, sprintf('A. Low GI (n = %d)', size(AIs_lgi, 1)), true);
ai_ssa_be(AIs_lgi, BE_lgi, p_SSA_lgi, p_BE_lgi, colors, AI_labels, 2, 'B', dot_ylim);

%% C, D: high-GI neurons (middle row)
psth_panel(subplot(3, 4, 5), PSTH_pophgi, col, S1_ON, sprintf('C. High GI (n = %d)', size(AIs_hgi, 1)), false);
ai_ssa_be(AIs_hgi, BE_hgi, p_SSA_hgi, p_BE_hgi, colors, AI_labels, 6, 'D', dot_ylim);

%% E, F, G: block effect of low- vs high-GI neurons (bottom row)
be_compare(subplot(3, 4, 9),  BE_lgi,      BE_hgi,      sprintf('E. vlPFC\\rightarrowIT, early (%s)', p_str(p_early)), dot_ylim);
be_compare(subplot(3, 4, 10), BE_lgi_rev,  BE_hgi_rev,  sprintf('F. IT\\rightarrowvlPFC (%s)', p_str(p_rev)), dot_ylim);
be_compare(subplot(3, 4, 11), BE_lgi_base, BE_hgi_base, sprintf('G. Baseline window (%s)', p_str(p_base)), dot_ylim);

%% ======================================================================
% Local functions

function psth_panel(ax, P, col, S1_ON, ttl, show_legend)
% Population PSTHs of the four conditions.
axes(ax);  hold on;
t_ms = (0:numel(P.RB_rep) - 1) - S1_ON;
hz = 1000;                                         % the PSTHs are saved in spikes/ms; x 1000 gives Hz
plot(t_ms, hz * P.RB_rep, 'Color', col.RB_rep, 'LineWidth', 2);
plot(t_ms, hz * P.RB_alt, 'Color', col.RB_alt, 'LineWidth', 2);
plot(t_ms, hz * P.AB_rep, 'Color', col.AB_rep, 'LineWidth', 2);
plot(t_ms, hz * P.AB_alt, 'Color', col.AB_alt, 'LineWidth', 2);
xline(0, ':k');  xline(100, ':k');  xline(400, ':k');  xline(500, ':k');
xlabel('Time from S1 onset (ms)');  ylabel('Firing rate (Hz)');
title(ttl);
if show_legend
    legend({'RB-Rep', 'RB-Alt', 'AB-Rep', 'AB-Alt'}, 'Location', 'northeast');  legend boxoff;
end
xlim([-100 800]);  box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);
end

function ai_ssa_be(AIs, BE, p_SSA, p_BE, colors, AI_labels, first, letter, dot_ylim)
% AI per condition, SSA per block and block effect, in three neighbouring
% subplots of the 3x4 grid starting at index "first".
yl = [-0.1 0.2];

% AI per condition
ax1 = subplot(3, 4, first);  hold on;
means = nanmean(AIs, 1);
sems  = nanstd(AIs, [], 1) ./ sqrt(sum(~isnan(AIs), 1));
errorbar(1:4, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
for i = 1:4
    plot(i, means(i), 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
end
xlim([0.5 4.5]);  ylim(yl);  set(gca, 'XTick', 1:4, 'XTickLabel', AI_labels);
ylabel('AI');  yline(0, 'k:');  title([letter '1. AI per condition']);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
dot_inset(ax1, {AIs(:, 1), AIs(:, 2), AIs(:, 3), AIs(:, 4)}, means, [0.5 4.5], AI_labels, dot_ylim);

% Stimulus-specific adaptation in each block
ax2 = subplot(3, 4, first + 1);  hold on;
SSA_RB = AIs(:, 1) - AIs(:, 2);
SSA_AB = AIs(:, 3) - AIs(:, 4);
meanSSA = [nanmean(SSA_RB), nanmean(SSA_AB)];
semSSA  = [nanstd(SSA_RB) / sqrt(sum(~isnan(SSA_RB))), nanstd(SSA_AB) / sqrt(sum(~isnan(SSA_AB)))];
errorbar([1 2], meanSSA, semSSA, 'k', 'LineStyle', 'none', 'LineWidth', 1);
plot([1 2], meanSSA, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
xlim([0.5 2.5]);  ylim(yl);  set(gca, 'XTick', [1 2], 'XTickLabel', {'RB', 'AB'});
ylabel('SSA');  yline(0, 'k:');  title(sprintf('%s2. SSA (%s)', letter, p_str(p_SSA)));
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
dot_inset(ax2, {SSA_RB, SSA_AB}, meanSSA, [0.5 2.5], {'RB', 'AB'}, dot_ylim);

% Block effect
ax3 = subplot(3, 4, first + 2);  hold on;
meanBE = nanmean(BE);  semBE = nanstd(BE) / sqrt(sum(~isnan(BE)));
errorbar(1, meanBE, semBE, 'k', 'LineStyle', 'none', 'LineWidth', 1);
plot(1, meanBE, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
xlim([0.5 1.5]);  ylim(yl);  set(gca, 'XTick', 1, 'XTickLabel', {'RB - AB'});
ylabel('Block effect');  yline(0, 'k:');  title(sprintf('%s3. BE (%s)', letter, p_str(p_BE)));
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
dot_inset(ax3, {BE}, meanBE, [0.5 1.5], {'RB - AB'}, dot_ylim);
end

function be_compare(ax, lo, hi, ttl, dot_ylim)
% Block effect of low- and high-GI neurons: grey bars (mean) with SEM. A narrow panel beside the bars shows every
% neuron as a tiny dot on its own y-axis (two columns, Low and High; red bar = mean).
axes(ax);  hold on;
means = [nanmean(lo), nanmean(hi)];
sems  = [nanstd(lo) / sqrt(sum(~isnan(lo))), nanstd(hi) / sqrt(sum(~isnan(hi)))];
bar(1:2, means, 'FaceColor', [0.85 0.85 0.85]);
errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
set(gca, 'XTick', 1:2, 'XTickLabel', {'Low', 'High'});  ylim([-0.05 0.15]);  ylabel('Block effect');
title(ttl);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
dot_inset(ax, {lo, hi}, means, [0.5 2.5], {'Low', 'High'}, dot_ylim);
end

function graded_dots(ax, x0, v, mu)
% Single neurons as tiny opaque dots at position x0 (jittered horizontally); no transparency. The grey level and
% the size depend on the rank of each neuron's distance from the mean mu divided by the number of neurons
% (t: 0 = closest, 1 = farthest) on a logarithmic scale: g = log10(1 + 9 t) from 0 (black) to 1 (white); the
% closest neurons are darkest and largest.
v = v(isfinite(v));
n = numel(v);
[~, ord] = sort(abs(v - mu), 'ascend');                % closest first
v = v(ord);
t = (0:n - 1)' / max(n - 1, 1);
g = log10(1 + 9 * t);
v = flipud(v);  g = flipud(g);                         % far (light) dots first, near (dark) dots on top
jit = (rand(n, 1) - 0.5) * 0.6;
sz = 1 + 4 * (1 - g);                                  % 5 (closest) ... 1 (farthest)
scatter(ax, x0 + jit, v, sz, [g g g], 'filled', 'MarkerEdgeColor', 'none');
end

function s = p_str(p)
% p-value as text, never printed as p = 0.
if p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end

function dot_inset(ax, vals, means, xl, xt, dot_ylim)
% The main axes keep the left part of their cell; a narrow panel beside them shows every neuron as a tiny opaque
% dot on its own y-axis, with the mean marked by a short red bar. The panel is numel(vals) columns wide, one column
% having the same width everywhere. vals: cell of column vectors; means: their means.
p = get(ax, 'Position');
set(ax, 'Position', [p(1), p(2), p(3) * 0.58, p(4)]);
unit = 0.075 * p(3);
axI = axes('Position', [p(1) + p(3) * 0.66, p(2), numel(vals) * unit, p(4)]);
hold(axI, 'on');
for k = 1:numel(vals)
    graded_dots(axI, k, vals{k}, means(k));
    plot(axI, k + [-0.3 0.3], [means(k) means(k)], 'r', 'LineWidth', 1.5);
end
xlim(axI, xl);  ylim(axI, dot_ylim);
yline(axI, 0, 'k:');
set(axI, 'XTick', 1:numel(vals), 'XTickLabel', xt, 'XTickLabelRotation', 45, 'FontSize', 6, 'TickDir', 'out', 'Box', 'off');
title(axI, 'Single neurons', 'FontSize', 8);
end