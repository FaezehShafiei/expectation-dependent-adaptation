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
% This script only draws the figure. The numbers come from fig3_data.mat,
% which fig3_analysis.m creates.
%
%   A  Population PSTHs of the four conditions, with an inset showing the
%      adaptation index (AI) for repeated (RT) and alternated (AT) trials,
%      collapsed across blocks
%   B  AI per condition, stimulus-specific adaptation (SSA) per block and
%      block effect (BE), full window (0-200 ms after response onset)
%   C  The same for the early window (0-100 ms)
%   D  The same for the late window (100-200 ms)
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
errorbar(1:2, AI_ins_means, AI_ins_sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
if p_repeated < 0.01
    text(1, AI_ins_means(1) + AI_ins_sems(1) + 0.01, '***', 'FontSize', 12, 'HorizontalAlignment', 'center');
end
if p_alternated < 0.01
    text(2, AI_ins_means(2) + AI_ins_sems(2) + 0.01, '***', 'FontSize', 12, 'HorizontalAlignment', 'center');
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
    subplot(4, 3, base + 1);  hold on;
    means = nanmean(d.AIs, 1);
    sems  = nanstd(d.AIs, [], 1) ./ sqrt(sum(~isnan(d.AIs), 1));
    errorbar(1:4, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    for i = 1:4
        plot(i, means(i), 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    end
    xlim([0.5 4.5]);  ylim([-0.15 0.15]);  set(gca, 'XTick', 1:4, 'XTickLabel', AI_labels);
    ylabel('AI');  yline(0, 'k:');
    title(d.label);  box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

    % Stimulus-specific adaptation in each block
    subplot(4, 3, base + 2);  hold on;
    meanSSA = [nanmean(d.SSA_RB), nanmean(d.SSA_AB)];
    semSSA  = [nanstd(d.SSA_RB) / sqrt(sum(~isnan(d.SSA_RB))), nanstd(d.SSA_AB) / sqrt(sum(~isnan(d.SSA_AB)))];
    errorbar([1 2], meanSSA, semSSA, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    plot([1 2], meanSSA, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    xlim([0.5 2.5]);  ylim([-0.15 0.15]);  set(gca, 'XTick', [1 2], 'XTickLabel', {'RB', 'AB'});
    ylabel('SSA');  yline(0, 'k:');
    title(sprintf('SSA (p=%.3g)', d.p_SSA));  box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

    % Block effect
    subplot(4, 3, base + 3);  hold on;
    meanBE = nanmean(d.BE);  semBE = nanstd(d.BE) / sqrt(sum(~isnan(d.BE)));
    errorbar(1, meanBE, semBE, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    plot(1, meanBE, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    xlim([0.5 1.5]);  ylim([-0.15 0.15]);  set(gca, 'XTick', 1, 'XTickLabel', {'RB - AB'});
    ylabel('Block effect');  yline(0, 'k:');
    title(sprintf('BE (p=%.3g)', d.p_BE));  box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
end
