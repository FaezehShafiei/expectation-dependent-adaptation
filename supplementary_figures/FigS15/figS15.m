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

%% figS15_plot.m
% Supplementary Fig. S15: justification of the 15 ms lag used for the Granger index in Fig. 5.
% This script only draws the figure. The numbers come from figS15_data.mat,
% which figS15_analysis.m creates.
%
%   A  out-of-sample GC (vlPFC -> IT) as a function of the length of the vlPFC history
%      (IT history fixed at pm ms); mean +- SEM across sessions
%   B  the same curve as a fraction of its value at pm ms (dotted line: 90%)
% Dashed line: 15 ms, the lag used in Fig. 5.
%
% Input:  figS15_data.mat (variables GC_cv, use, pm, remove_evoked)
% Output: the figure window

clc; clear; close all;
load('figS15_data.mat');

col = [0.20 0.45 0.75];
q = 1:pm;  ns = sum(use);
gm = mean(GC_cv(use, :), 1);
se = std(GC_cv(use, :), 0, 1) / sqrt(ns);

figure('Color', 'w', 'Position', [40 40 900 380]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
letter = @(k) text(-0.17, 1.08, char('A' + k - 1), 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 13);

%% A: GC against the length of the vlPFC history
nexttile;  hold on;  letter(1);
fill([q, fliplr(q)], [gm - se, fliplr(gm + se)], col, 'FaceAlpha', 0.18, 'EdgeColor', 'none');
plot(q, gm, '-', 'Color', col, 'LineWidth', 1.6);
xline(15, 'k--');
xlabel('Length of the vlPFC history (ms)');
ylabel('Out-of-sample GC (vlPFC \rightarrow IT)');
box off;  set(gca, 'TickDir', 'out');

%% B: same curve as a fraction of the value at pm ms
nexttile;  hold on;  letter(2);
plot(q, gm / gm(pm), '-', 'Color', col, 'LineWidth', 1.6);
yline(0.9, 'k:');  xline(15, 'k--');  ylim([0 1.15]);
xlabel('Length of the vlPFC history (ms)');
ylabel(sprintf('Fraction of the GC at %d ms', pm));
box off;  set(gca, 'TickDir', 'out');