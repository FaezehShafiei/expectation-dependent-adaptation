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


% Supplementary Fig. S7: block effect of IT in short epochs (width set by
% epw in figS7_analysis.m, 50 or 25 ms) from 50 ms before to 300 ms after
% time 0. 
%
%   A  time 0 = population-mean response onset (the -50 to 0 ms epoch
%      precedes the response and serves as a baseline)
%   B  time 0 = stimulus onset
%
% Block effect (BE = SSA in RB - SSA in AB), mean +- SEM across neurons.
% The p value above each point is BE against zero (two-sided t-test across
% neurons). Differences between epochs are not shown.
%
% Input:  figS7_data.mat (variables R, aligns, epw)
% Output: the figure window

clc; clear; close all;
load('figS7_data.mat', 'R', 'aligns', 'epw');

xl = {'Time from response onset (ms)', 'Time from stimulus onset (ms)'};
nE = size(R.response.ep, 1);
dense = nE > 8;                                   % 25 ms epochs: smaller labels, rotated p values
yl = [-0.1, 0.2 + 0.05 * dense];

figure('Color', 'w', 'Position', [60 100 1300 + 400 * dense 500]);
for k = 1:2
    r = R.(aligns{k});
    subplot(1, 2, k);  hold on;
    lab = arrayfun(@(e) sprintf('%d to %d', r.ep(e, 1), r.ep(e, 2)), 1:nE, 'UniformOutput', false);
    errorbar(1:nE, r.mBE, r.sBE, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    plot(1:nE, r.mBE, 'o', 'MarkerFaceColor', [0.3 0.6 0.9], 'MarkerEdgeColor', 'k', 'MarkerSize', 7);
    for e = 1:nE
        if dense
            text(e, r.mBE(e) + r.sBE(e) + 0.01, ['p ' fmt_p(r.p_BE(e))], 'Rotation', 90, 'HorizontalAlignment', 'left', 'FontSize', 8);
        else
            text(e, r.mBE(e) + r.sBE(e) + 0.015, ['p ' fmt_p(r.p_BE(e))], 'HorizontalAlignment', 'center', 'FontSize', 9);
        end
    end
    xlim([0.5 nE + 0.5]);  ylim(yl);
    set(gca, 'XTick', 1:nE, 'XTickLabel', lab, 'XTickLabelRotation', 45 * dense);
    xlabel(xl{k});  ylabel('Block effect');
    yline(0, 'k:');
    box off;  set(gca, 'TickDir', 'out', 'FontSize', 11 - 2 * dense);
    text(-0.14, 1.06, char('A' + k - 1), 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold', 'Clipping', 'off');
end

%% ======================================================================
% Local functions

function s = fmt_p(p)
% p-value as text, without the leading "p" (used as "p %s").
if isnan(p), s = 'NaN'; elseif p < 0.001, s = '< 0.001'; else, s = sprintf('= %.3f', p); end
end