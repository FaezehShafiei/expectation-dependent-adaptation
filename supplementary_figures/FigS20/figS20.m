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

%% figS20_plot.m
% Supplementary Fig. S20: Fig. 5 for each monkey separately (IT).
% This script only draws the figure. The numbers come from figS20_data.mat,
% which figS20_analysis.m creates.
%
%   A, B  Monkey F and Monkey V, low-GI neurons, late window (100-200 ms after the response onset): AI of repeated
%         (RT) and alternated (AT) trials in the repeating (RB) and alternating (AB) block, stimulus-specific
%         adaptation (SSA = AI(RT) - AI(AT)) and block effect (BE = SSA_RB - SSA_AB)
%   C, D  the same for high-GI neurons
%   E-G   BE of low- and high-GI neurons in Monkey F and Monkey V, for the vlPFC -> IT GI in the early window (E),
%         the IT -> vlPFC GI in the early window (F) and the vlPFC -> IT GI in the baseline window (G)
% Points and bars show the mean across neurons, error bars the SEM. Stars above the BE of a group: one-sample
% t-test against 0. Stars on the brackets in E-G: rank-sum test, low vs high GI (* p < 0.05, ** p < 0.01,
% *** p < 0.001, n.s. not significant).
%
% Input:  figS20_data.mat
% Output: the figure window

clc; clear; close all;
load('figS20_data.mat');

col.RB_rep = [0.80 0.10 0.10];
col.RB_alt = [0.95 0.55 0.15];
col.AB_rep = [0.10 0.35 0.95];
col.AB_alt = [0.40 0.70 1.00];
yl_ai = [-.15 .15];                            % y axis of the AI, SSA and BE panels (A-D)
grey_low  = [0.72 0.74 0.73];
grey_high = [0.35 0.38 0.37];

figure('Color', 'w', 'Position', [40 40 1300 1250]);
tiledlayout(3, 6, 'TileSpacing', 'compact', 'Padding', 'compact');

%% A-D: AI, SSA and BE of low- and high-GI neurons in each monkey
for m = monkeys
    d = bymonkey(m);
    first_lo = 1 + (m - 1) * 3;                   % tiles of the first row
    first_hi = 7 + (m - 1) * 3;                   % tiles of the second row
    ai_ssa_be(d.AIs_lgi, d.BE_lgi, d.p_BE_lgi, col, yl_ai, first_lo, char('A' + m - 1), ...
        sprintf('%s, low GI (n = %d)', monkey_names{m}, size(d.AIs_lgi, 1)), true);
    ai_ssa_be(d.AIs_hgi, d.BE_hgi, d.p_BE_hgi, col, yl_ai, first_hi, char('C' + m - 1), ...
        sprintf('%s, high GI (n = %d)', monkey_names{m}, size(d.AIs_hgi, 1)), false);
end

%% E-G: block effect of low- vs high-GI neurons
be_compare(13, 'E', bymonkey, monkeys, {'BE_lgi', 'BE_hgi'},           'p_early', grey_low, grey_high, ...
    sprintf('vlPFC \\rightarrow IT (early window) GI'), true);
be_compare(15, 'F', bymonkey, monkeys, {'BE_lgi_rev', 'BE_hgi_rev'},   'p_rev',   grey_low, grey_high, ...
    sprintf('IT \\rightarrow vlPFC (early window) GI'), false);
be_compare(17, 'G', bymonkey, monkeys, {'BE_lgi_base', 'BE_hgi_base'}, 'p_base',  grey_low, grey_high, ...
    sprintf('vlPFC \\rightarrow IT (baseline window) GI'), false);

%% ======================================================================
% Local functions

function ai_ssa_be(AIs, BE, p_BE, col, yl, first, letter, ttl, show_late)
% AI per condition (RT and AT, RB and AB), SSA of the two blocks and block effect, in three neighbouring tiles.
nexttile(first);  hold on;
m = mean(AIs, 1);  se = std(AIs, 0, 1) ./ sqrt(sum(~isnan(AIs), 1));
cl = [col.RB_rep; col.RB_alt; col.AB_rep; col.AB_alt];
xs = [0.9 2.1 1.1 1.9];                                  % RB-RT, RB-AT, AB-RT, AB-AT
plot(xs([1 2]), m([1 2]), 'k-');                          % RB: RT -> AT
plot(xs([3 4]), m([3 4]), 'k-');                          % AB: RT -> AT
errorbar(xs, m, se, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
for i = 1:4
    plot(xs(i), m(i), 'o', 'MarkerFaceColor', cl(i, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
end
yline(0, 'k:');  xlim([0.5 2.5]);  ylim(yl);
set(gca, 'XTick', [1 2], 'XTickLabel', {'RT', 'AT'});
ylabel('AI');
text(-0.35, 1.08, letter, 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 14);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

nexttile(first + 1);  hold on;
SSA_RB = AIs(:, 1) - AIs(:, 2);  SSA_AB = AIs(:, 3) - AIs(:, 4);
ms = [mean(SSA_RB), mean(SSA_AB)];
ss = [std(SSA_RB) / sqrt(numel(SSA_RB)), std(SSA_AB) / sqrt(numel(SSA_AB))];
plot([1 2], ms, 'k-');
errorbar([1 2], ms, ss, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
plot(1, ms(1), 'o', 'MarkerFaceColor', col.RB_rep, 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
plot(2, ms(2), 'o', 'MarkerFaceColor', col.AB_alt, 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
yline(0, 'k:');  xlim([0.5 2.5]);  ylim(yl);
set(gca, 'XTick', [1 2], 'XTickLabel', {'RB', 'AB'});
if show_late
    title({ttl, 'Late (100-200 ms after response onset)'}, 'FontWeight', 'normal');
else
    title(ttl, 'FontWeight', 'normal');
end
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);

nexttile(first + 2);  hold on;
mb = mean(BE);  sb = std(BE) / sqrt(numel(BE));
errorbar(1, mb, sb, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
plot(1, mb, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
yline(0, 'k:');  xlim([0.5 1.5]);  ylim(yl);
set(gca, 'XTick', 1, 'XTickLabel', {'Block effect'});
text(1, yl(2) * 0.93, stars_of(p_BE), 'HorizontalAlignment', 'center', 'FontSize', 12);
text(1, yl(1) + 0.55 * (yl(2) - yl(1)), p_str(p_BE), 'HorizontalAlignment', 'center', 'FontSize', 8);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
end

function be_compare(first, letter, bymonkey, monkeys, fields, pfield, grey_low, grey_high, xlab, show_ylabel)
% BE of low- and high-GI neurons in both monkeys, with a bracket and stars for low vs high GI.
nexttile(first, [1 2]);  hold on;
xpos = [1 2; 3.4 4.4];                                   % [low high] of Monkey F, then Monkey V
top = -inf;  bot = inf;
for m = monkeys
    lo = bymonkey(m).(fields{1});  hi = bymonkey(m).(fields{2});
    mu = [mean(lo), mean(hi)];
    se = [std(lo) / sqrt(numel(lo)), std(hi) / sqrt(numel(hi))];
    bar(xpos(m, 1), mu(1), 0.8, 'FaceColor', grey_low,  'EdgeColor', 'k');
    bar(xpos(m, 2), mu(2), 0.8, 'FaceColor', grey_high, 'EdgeColor', 'k');
    errorbar(xpos(m, :), mu, se, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);
    top = max([top, mu + se]);  bot = min([bot, mu - se, 0]);
end
rng_y = top - bot;
ylim([bot, top + 0.30 * rng_y]);
for m = monkeys
    yb = top + 0.10 * rng_y;
    plot([xpos(m, 1) xpos(m, 1) xpos(m, 2) xpos(m, 2)], [yb - 0.03 * rng_y, yb, yb, yb - 0.03 * rng_y], 'k-');
    text(mean(xpos(m, :)), yb + 0.02 * rng_y, stars_of(bymonkey(m).(pfield)), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'FontSize', 11);
end
set(gca, 'XTick', reshape(xpos', 1, []), 'XTickLabel', {'Low', 'High', 'Low', 'High'});
xlim([0.2 5.2]);
yl = ylim;
mk = {'Monkey F', 'Monkey V'};
for m = monkeys
    text(mean(xpos(m, :)), yl(1) - 0.16 * (yl(2) - yl(1)), mk{m}, 'HorizontalAlignment', 'center', ...
        'FontSize', 9, 'Clipping', 'off');
end
xlabel({' ', ' ', xlab});                                % leave room for the monkey labels
if show_ylabel, ylabel('Block effect'); end
text(-0.12, 1.05, letter, 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 14);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
end

function s = stars_of(p)
if p < 0.001, s = '***'; elseif p < 0.01, s = '**'; elseif p < 0.05, s = '*'; else, s = 'n.s.'; end
end

function s = p_str(p)
if p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end