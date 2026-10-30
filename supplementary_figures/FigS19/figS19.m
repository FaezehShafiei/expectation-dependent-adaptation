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

%% figS19_plot.m
% Supplementary Fig. S19: block effect of IT neurons with low and high baseline-window GI (vlPFC -> IT).
% This script only draws the figure. The numbers come from figS19_data.mat,
% which figS19_analysis.m creates.
%
%   A  low-GI neurons, late window (100-200 ms after the population-mean response onset): AI of repeated (RT) and
%      alternated (AT) trials in the repeating (RB) and alternating (AB) block, stimulus-specific adaptation
%      (SSA = AI(RT) - AI(AT)) and block effect (BE = SSA_RB - SSA_AB; * p < 0.05, one-sample t-test against 0)
%   B  the same for high-GI neurons
% Points show the mean across neurons, error bars the SEM.
%
% Input:  figS19_data.mat
% Output: the figure window

clc; clear; close all;
load('figS19_data.mat');

col.RB_rep = [0.80 0.10 0.10];
col.RB_alt = [0.95 0.55 0.15];
col.AB_rep = [0.10 0.35 0.95];
col.AB_alt = [0.40 0.70 1.00];
yl_ai = [-0.1 0.15];

figure('Color', 'w', 'Position', [40 40 900 700]);
tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
ai_ssa_be(AIs_lgi, BE_lgi, p_BE_lgi, col, yl_ai, 1, 'A');
ai_ssa_be(AIs_hgi, BE_hgi, p_BE_hgi, col, yl_ai, 4, 'B');

%% ======================================================================
% Local functions

function ai_ssa_be(AIs, BE, p_BE, col, yl, first, letter)
% AI per condition (RT and AT, RB and AB), SSA of the two blocks and block effect, in three neighbouring tiles.
nexttile(first);  hold on;
m = mean(AIs, 1);  se = std(AIs, 0, 1) ./ sqrt(sum(~isnan(AIs), 1));
cl = [col.RB_rep; col.RB_alt; col.AB_rep; col.AB_alt];
xs = [0.9 2.1 1.1 1.9];                                  % RB-RT, RB-AT, AB-RT, AB-AT
plot(xs([1 2]), m([1 2]), 'k-');                          % RB: RT -> AT
plot(xs([3 4]), m([3 4]), 'k-');                          % AB: RT -> AT
errorbar(xs, m, se, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
for i = 1:4
    plot(xs(i), m(i), 'o', 'MarkerFaceColor', cl(i, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 7);
end
yline(0, 'k:');  xlim([0.5 2.5]);  ylim(yl);
set(gca, 'XTick', [1 2], 'XTickLabel', {'RT', 'AT'});
ylabel('AI');
text(-0.35, 1.08, letter, 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 14);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);

nexttile(first + 1);  hold on;
SSA_RB = AIs(:, 1) - AIs(:, 2);  SSA_AB = AIs(:, 3) - AIs(:, 4);
ms = [mean(SSA_RB), mean(SSA_AB)];
ss = [std(SSA_RB) / sqrt(numel(SSA_RB)), std(SSA_AB) / sqrt(numel(SSA_AB))];
plot([1 2], ms, 'k-');
errorbar([1 2], ms, ss, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
plot(1, ms(1), 'o', 'MarkerFaceColor', col.RB_rep, 'MarkerEdgeColor', 'k', 'MarkerSize', 7);
plot(2, ms(2), 'o', 'MarkerFaceColor', col.AB_alt, 'MarkerEdgeColor', 'k', 'MarkerSize', 7);
yline(0, 'k:');  xlim([0.5 2.5]);  ylim(yl);
set(gca, 'XTick', [1 2], 'XTickLabel', {'RB', 'AB'});
title('Late (100-200 ms after response onset)', 'FontWeight', 'normal');
xlabel('Stimulus specific adaptation');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);

nexttile(first + 2);  hold on;
mb = mean(BE);  sb = std(BE) / sqrt(numel(BE));
errorbar(1, mb, sb, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
plot(1, mb, 'o', 'MarkerFaceColor', col.AB_alt, 'MarkerEdgeColor', 'k', 'MarkerSize', 7);
yline(0, 'k:');  xlim([0.5 1.5]);  ylim(yl);
set(gca, 'XTick', 1, 'XTickLabel', {'Block effect'});
text(1, yl(2) * 0.95, stars_of(p_BE), 'HorizontalAlignment', 'center', 'FontSize', 13);
text(1, yl(1) + 0.55 * (yl(2) - yl(1)), p_str(p_BE), 'HorizontalAlignment', 'center', 'FontSize', 9);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);
end

function s = stars_of(p)
if p < 0.001, s = '***'; elseif p < 0.01, s = '**'; elseif p < 0.05, s = '*'; else, s = 'n.s.'; end
end

function s = p_str(p)
if p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end