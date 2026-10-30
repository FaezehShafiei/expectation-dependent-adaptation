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
% This script only draws the figure. The numbers come from fig5_data.mat,
% which fig5_analysis.m creates.
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
% Points show the mean across neurons; error bars are the SEM. In E-G the
% grey bars are the means and the faint dots are single neurons (jittered
% horizontally).
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
pt_alpha = 0.05;                             % transparency of the single-neuron dots
jit = 0.08;                                  % horizontal jitter (half-width)

figure('Color', 'w', 'Position', [50 50 1600 1100]);

%% A, B: low-GI neurons (top row)
psth_panel(subplot(3, 4, 1), PSTH_poplgi, col, S1_ON, sprintf('A. Low GI (n = %d)', size(AIs_lgi, 1)), true);
ai_ssa_be(AIs_lgi, BE_lgi, p_SSA_lgi, p_BE_lgi, colors, AI_labels, 2, 'B');

%% C, D: high-GI neurons (middle row)
psth_panel(subplot(3, 4, 5), PSTH_pophgi, col, S1_ON, sprintf('C. High GI (n = %d)', size(AIs_hgi, 1)), false);
ai_ssa_be(AIs_hgi, BE_hgi, p_SSA_hgi, p_BE_hgi, colors, AI_labels, 6, 'D');

%% E, F, G: block effect of low- vs high-GI neurons (bottom row)
be_compare(subplot(3, 4, 9),  BE_lgi,      BE_hgi,      sprintf('E. vlPFC\\rightarrowIT, early (%s)', p_str(p_early)), jit, pt_alpha);
be_compare(subplot(3, 4, 10), BE_lgi_rev,  BE_hgi_rev,  sprintf('F. IT\\rightarrowvlPFC (%s)', p_str(p_rev)),         jit, pt_alpha);
be_compare(subplot(3, 4, 11), BE_lgi_base, BE_hgi_base, sprintf('G. Baseline window (%s)', p_str(p_base)),            jit, pt_alpha);

%% ======================================================================
% Local functions

function psth_panel(ax, P, col, S1_ON, ttl, show_legend)
% Population PSTHs of the four conditions.
axes(ax);  hold on;
t_ms = (0:numel(P.RB_rep) - 1) - S1_ON;
plot(t_ms, P.RB_rep, 'Color', col.RB_rep, 'LineWidth', 2);
plot(t_ms, P.RB_alt, 'Color', col.RB_alt, 'LineWidth', 2);
plot(t_ms, P.AB_rep, 'Color', col.AB_rep, 'LineWidth', 2);
plot(t_ms, P.AB_alt, 'Color', col.AB_alt, 'LineWidth', 2);
xline(0, ':k');  xline(100, ':k');  xline(400, ':k');  xline(500, ':k');
xlabel('Time from S1 onset (ms)');  ylabel('Firing rate (Hz)');
title(ttl);
if show_legend
    legend({'RB-Rep', 'RB-Alt', 'AB-Rep', 'AB-Alt'}, 'Location', 'northeast');  legend boxoff;
end
xlim([-100 800]);  box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);
end

function ai_ssa_be(AIs, BE, p_SSA, p_BE, colors, AI_labels, first, letter)
% AI per condition, SSA per block and block effect, in three neighbouring
% subplots of the 3x4 grid starting at index "first".
yl = [-0.1 0.2];

% AI per condition
subplot(3, 4, first);  hold on;
means = nanmean(AIs, 1);
sems  = nanstd(AIs, [], 1) ./ sqrt(sum(~isnan(AIs), 1));
errorbar(1:4, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
for i = 1:4
    plot(i, means(i), 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
end
xlim([0.5 4.5]);  ylim(yl);  set(gca, 'XTick', 1:4, 'XTickLabel', AI_labels);
ylabel('AI');  yline(0, 'k:');  title([letter '1. AI per condition']);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

% Stimulus-specific adaptation in each block
subplot(3, 4, first + 1);  hold on;
SSA_RB = AIs(:, 1) - AIs(:, 2);
SSA_AB = AIs(:, 3) - AIs(:, 4);
meanSSA = [nanmean(SSA_RB), nanmean(SSA_AB)];
semSSA  = [nanstd(SSA_RB) / sqrt(sum(~isnan(SSA_RB))), nanstd(SSA_AB) / sqrt(sum(~isnan(SSA_AB)))];
errorbar([1 2], meanSSA, semSSA, 'k', 'LineStyle', 'none', 'LineWidth', 1);
plot([1 2], meanSSA, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
xlim([0.5 2.5]);  ylim(yl);  set(gca, 'XTick', [1 2], 'XTickLabel', {'RB', 'AB'});
ylabel('SSA');  yline(0, 'k:');  title(sprintf('%s2. SSA (%s)', letter, p_str(p_SSA)));
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

% Block effect
subplot(3, 4, first + 2);  hold on;
meanBE = nanmean(BE);  semBE = nanstd(BE) / sqrt(sum(~isnan(BE)));
errorbar(1, meanBE, semBE, 'k', 'LineStyle', 'none', 'LineWidth', 1);
plot(1, meanBE, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
xlim([0.5 1.5]);  ylim(yl);  set(gca, 'XTick', 1, 'XTickLabel', {'RB - AB'});
ylabel('Block effect');  yline(0, 'k:');  title(sprintf('%s3. BE (%s)', letter, p_str(p_BE)));
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
end

function be_compare(ax, lo, hi, ttl, jit, pt_alpha)
% Block effect of low- and high-GI neurons: grey bars (mean), SEM, and
% the single neurons as faint jittered dots.
axes(ax);  hold on;
xj1 = 1 + (rand(length(lo), 1) - 0.5) * 2 * jit;
xj2 = 2 + (rand(length(hi), 1) - 0.5) * 2 * jit;
means = [nanmean(lo), nanmean(hi)];
sems  = [nanstd(lo) / sqrt(length(lo)), nanstd(hi) / sqrt(length(hi))];
bar(1:2, means, 'FaceColor', [0.85 0.85 0.85]);
scatter(xj1, lo, 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', pt_alpha);
scatter(xj2, hi, 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', pt_alpha);
errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
set(gca, 'XTick', 1:2, 'XTickLabel', {'Low', 'High'});  ylim([-0.5 0.5]);  ylabel('Block effect');
title(ttl);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
end

function s = p_str(p)
% p-value as text, never printed as p = 0.
if p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end