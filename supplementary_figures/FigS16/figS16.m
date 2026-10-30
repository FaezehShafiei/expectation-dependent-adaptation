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

%  Fig. S16: GI does not depend on recent trial history, and BE grows with GI.
%
%   A  per-session t-statistic of each trial-history predictor of GI (violins, one dot per session); the p-value
%      above each violin is the test of the mean t against 0
%   B  GI (raw) by preceding trial type (RT = repetition trial, AT = alternation trial)
%   C  GI by recent repetition rate
%   D  GI by trial position within the block (100-trial bins)
%   E  GI by run length
%      B-E: mean +/- SEM across sessions
%   F  SSA in the repeating (RB) and alternating (AB) block for low- and high-GI neurons
%   G  block effect (BE) of low- and high-GI neurons (* p < 0.05, ** p < 0.01, *** p < 0.001, n.s. not
%      significant; one-sample t-test against 0)
%   H  BE in three GI bins of each neuron (mean +/- SEM across neurons)
%   I  null distribution of the mean slope of BE over the GI bins (circularly shifted GI sequences); the red line
%      is the observed slope
%
% Input:  figS16_data.mat
% Output: the figure window

clc; clear; close all;
load('figS16_data.mat');

blue = [0.20 0.40 0.80];
red  = [0.85 0.20 0.20];

figure('Color', 'w', 'Position', [40 40 1400 1500]);
tiledlayout(3, 12, 'TileSpacing', 'compact', 'Padding', 'compact');
letter = @(s) text(-0.12, 1.10, s, 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 14);

%% A: t-statistics of the trial-history predictors
nexttile(1, [1 7]);  hold on;  letter('A');
labels = {'Preceding trial type', 'Run length', 'Recent rep. rate', 'Trial position'};
for p = 1:4
    plot_violin_scatter(p, tStats(:, p), 0.35, [0.75 0.75 0.85], [0.3 0.3 0.3]);
end
yline(0, 'k--', 'LineWidth', 1);
xlim([0.5 4.5]);
set(gca, 'XTick', 1:4, 'XTickLabel', labels);  xtickangle(20);
ylabel('t-statistic');
title('Per-session GI ~ trial history', 'FontWeight', 'normal');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
yl = ylim;  ylim([yl(1), yl(2) + 0.15 * (yl(2) - yl(1))]);    % headroom for the p-values
yl = ylim;
for p = 1:4
    text(p, yl(2) - 0.05 * (yl(2) - yl(1)), p_txt(p_vs0(p)), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', 'FontSize', 8);
end

%% B: preceding trial type
nexttile(9, [1 4]);  hold on;  letter('B');
[m, se] = mean_sem(byPrevType);
errorbar(1:2, m, se, '-o', 'Color', blue, 'MarkerFaceColor', blue, 'LineWidth', 1.5, 'MarkerSize', 8);
set(gca, 'XTick', 1:2, 'XTickLabel', {'RT', 'AT'});  xlim([0.5 2.5]);
xlabel('Preceding trial type');  ylabel('GI (raw)');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% C: recent repetition rate
nexttile(13, [1 4]);  hold on;  letter('C');
[m, se] = mean_sem(byRecentRep);
nb = numel(m);
errorbar(1:nb, m, se, '-o', 'Color', red, 'MarkerFaceColor', red, 'LineWidth', 1.5, 'MarkerSize', 6);
set(gca, 'XTick', 1:nb, 'XTickLabel', {'20', '40', '60', '80', '100'});  xlim([0.5 nb + 0.5]);
xlabel('Recent repetition rate (%)');  ylabel('GI (raw)');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% D: trial position within the block
nexttile(17, [1 4]);  hold on;  letter('D');
[m, se] = mean_sem(byTrialPos);
nb = numel(m);
errorbar(1:nb, m, se, '-o', 'Color', red, 'MarkerFaceColor', red, 'LineWidth', 1.5, 'MarkerSize', 6);
xl = arrayfun(@(i) sprintf('%d:%d', tp_edges(i) + 1, tp_edges(i + 1)), 1:nb, 'UniformOutput', false);
set(gca, 'XTick', 1:nb, 'XTickLabel', xl);  xtickangle(45);  xlim([0.5 nb + 0.5]);
xlabel('Trial position within block');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% E: run length
nexttile(21, [1 4]);  hold on;  letter('E');
[m, se] = mean_sem(byRunLength);
nb = numel(m);
errorbar(1:nb, m, se, '-o', 'Color', red, 'MarkerFaceColor', red, 'LineWidth', 1.5, 'MarkerSize', 6);
set(gca, 'XTick', 1:nb, 'XTickLabel', {'1', '2', '3', '4', '5', '6+'});  xlim([0.5 nb + 0.5]);
xlabel('Run length');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% F: SSA of the repeating and alternating block, low and high GI
nexttile(25, [1 3]);  hold on;  letter('F');
xs = [1 2 3.6 4.6];
grp = {SSA_RB_lgi, SSA_AB_lgi, SSA_RB_hgi, SSA_AB_hgi};
m = cellfun(@mean, grp);
se = cellfun(@(v) std(v) / sqrt(numel(v)), grp);
cols = {[0.9 0.1 0.1], [0.1 0.4 0.95], [0.9 0.1 0.1], [0.1 0.4 0.95]};
for g = [1 3]
    plot(xs(g:g + 1), m(g:g + 1), 'k-', 'LineWidth', 1);
end
errorbar(xs, m, se, 'Color', [0.35 0.35 0.35], 'LineStyle', 'none', 'LineWidth', 1.5);
for g = 1:4
    plot(xs(g), m(g), 'o', 'MarkerFaceColor', cols{g}, 'MarkerEdgeColor', 'none', 'MarkerSize', 5);
end
yline(0, 'k:');
set(gca, 'XTick', xs, 'XTickLabel', {'RB', 'AB', 'RB', 'AB'});  xlim([0.4 5.2]);
ylabel('SSA');
yl = ylim;  ylim([yl(1) - 0.02, yl(2)]);  yl = ylim;
text(1.5, yl(1) + 0.40 * (yl(2) - yl(1)), p_str(p_SSA_lgi), 'HorizontalAlignment', 'center', 'FontSize', 8);
text(4.1, yl(1) + 0.45 * (yl(2) - yl(1)), p_str(p_SSA_hgi), 'HorizontalAlignment', 'center', 'FontSize', 8);
text(1.5, yl(1) - 0.16 * (yl(2) - yl(1)), 'Low GI',  'HorizontalAlignment', 'center', 'FontSize', 9, 'Clipping', 'off');
text(4.1, yl(1) - 0.16 * (yl(2) - yl(1)), 'High GI', 'HorizontalAlignment', 'center', 'FontSize', 9, 'Clipping', 'off');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% G: block effect, low and high GI
nexttile(28, [1 3]);  hold on;  letter('G');
m = [mean(BE_lgi), mean(BE_hgi)];
se = [std(BE_lgi) / sqrt(numel(BE_lgi)), std(BE_hgi) / sqrt(numel(BE_hgi))];
bar(1:2, m, 0.6, 'FaceColor', [0.8 0.8 0.8]);
errorbar(1:2, m, se, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
set(gca, 'XTick', 1:2, 'XTickLabel', {'Low GI', 'High GI'});  xlim([0.3 2.7]);
ylabel('Block effect');
yl = ylim;  ylim([yl(1), yl(2) + 0.12 * (yl(2) - yl(1))]);  yl = ylim;
text(1, m(1) + se(1) + 0.02 * (yl(2) - yl(1)), stars_of(p_BE_lgi), 'HorizontalAlignment', 'center', 'FontSize', 11);
text(2, m(2) + se(2) + 0.02 * (yl(2) - yl(1)), stars_of(p_BE_hgi), 'HorizontalAlignment', 'center', 'FontSize', 11);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% H: BE in GI bins
nexttile(31, [1 3]);  hold on;  letter('H');
mu = mean(be_bins(ok, :), 1);
sem = std(be_bins(ok, :), 0, 1) / sqrt(numel(ok));
errorbar(1:n_bins, mu, sem, 'k-o', 'LineWidth', 1.8, 'MarkerFaceColor', 'k', 'MarkerSize', 5);
set(gca, 'XTick', 1:n_bins);  xlim([0.5 n_bins + 0.5]);
xlabel('GI bin (low to high)');  ylabel('Block effect');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% I: shift permutation of the slope
nexttile(34, [1 3]);  hold on;  letter('I');
histogram(null_slope, 30, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
xline(obs, 'r-', 'LineWidth', 2);
xlabel('Mean slope of BE over GI bins');  ylabel('GI shifts');
title(sprintf('permutation p %s', fmt_p(p_perm)), 'FontWeight', 'bold');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

%% ======================================================================
% Local functions

function [m, se] = mean_sem(x)
% Mean and SEM across sessions (rows), ignoring NaN.
m  = mean(x, 1, 'omitnan');
se = std(x, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(x), 1));
end

function s = p_txt(p)
% p-value above the violins.
if p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3g', p); end
end

function s = p_str(p)
if p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end

function s = fmt_p(p)
if p < 0.001, s = '< 0.001'; else, s = sprintf('= %.3f', p); end
end

function s = stars_of(p)
if p < 0.001, s = '***'; elseif p < 0.01, s = '**'; elseif p < 0.05, s = '*'; else, s = 'n.s.'; end
end

function plot_violin_scatter(x_center, data, max_half_width, violin_color, dot_color)
% Draws a violin (mirrored kernel-density shape) centered at x_center,
% then overlays each data point using a deterministic "swarm" layout:
% points are packed outward from the centerline in alternating
% left/right order, with each point's maximum offset capped by the
% violin's own local width AT THAT POINT'S y-value - so points in dense
% regions can spread wide (up to the violin edge) while points in sparse
% tails stay close to the centerline. This is more reliable than random
% jitter scaled by width, which can look uniform by chance. data may
% contain NaNs (ignored).
data = data(~isnan(data));
if numel(data) < 5
    return   % not enough points for a meaningful density estimate
end
[f, xi] = ksdensity(data);
f_scaled = f / max(f) * max_half_width;   % scale so the widest point = max_half_width
fill([x_center - f_scaled, fliplr(x_center + f_scaled)], [xi, fliplr(xi)], violin_color, ...
    'EdgeColor', [0.4 0.4 0.5], 'FaceAlpha', 0.6);

% each point's local half-width, via interpolation of the same density
% curve used to draw the violin
local_halfwidth = interp1(xi, f_scaled, data, 'linear', 0);

% deterministic swarm: sort by y, then place points alternately
% left/right at increasing packing steps, capped by local width
[sorted_data, order] = sort(data);
sorted_halfwidth = local_halfwidth(order);
n = numel(sorted_data);
x_offset = zeros(n,1);
step = 0.06;   % horizontal spacing between packed points, in x_center units
% group points into y-bands (points close in y compete for the same
% horizontal slots) so packing order reflects local crowding
band_width = range(sorted_data) / 40;
if band_width == 0
    band_width = 1;
end
band_id = round((sorted_data - min(sorted_data)) / band_width);
for b = unique(band_id)'
    idx = find(band_id == b);
    for k = 1:numel(idx)
        side = (-1)^k;   % alternate left/right
        rank = ceil(k/2);
        raw_offset = side * rank * step;
        cap = sorted_halfwidth(idx(k)) * 0.9;
        x_offset(idx(k)) = max(min(raw_offset, cap), -cap);
    end
end
final_x = x_center + x_offset;
final_x(order) = final_x;   % undo the sort, back to original data order
scatter(final_x, data, 14, 'MarkerFaceColor', dot_color, 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.5);
end