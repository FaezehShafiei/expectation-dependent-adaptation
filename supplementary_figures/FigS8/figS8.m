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

% Fig. S8: fixation-break rate and pupil size in the repeating
% (RB), neutral and alternating (AB) block.
% 
%   A  fixation-break rate per session in RB, neutral and AB (bars = mean +- SEM).
%      Title: repeated-measures ANOVA over the three blocks.
%   B  pupil diameter before S2 (550-650 ms) in RB, neutral and AB.
%      Title: repeated-measures ANOVA over the three blocks.
%   C  pupil response to S2 (650-900 ms minus pre-S2) for expected and
%      unexpected trials. Title: paired t-test.
%
% Grey circles = sessions, thin grey lines join the conditions of a session.
% In B and C the filled circle with error bars (on top) = mean +- SEM across
% sessions. Sessions without a neutral block are drawn in RB and AB only.
%
% Input:  figS8_fixbreak_data.mat, figS8_pupil_data.mat
% Output: the figure window

clc; clear; close all;
FB = load('figS8_fixbreak_data.mat');             % rate, use, p_F, F_block, df1, df2, ...
PU = load('figS8_pupil_data.mat');                % pre_block, resp_exp, resp_unexp, use, p_F_pre, ...

cB = [0.80 0.10 0.10; 0.30 0.30 0.30; 0.10 0.35 0.95];     % RB, neutral, AB
cE = [0.35 0.35 0.35; 0.95 0.60 0.10];                      % expected, unexpected
letter = @(k) text(-0.22, 1.08, [char('A' + k - 1) '.'], 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 13);

figure('Color', 'w', 'Position', [60 60 1250 400]);
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% ---- A: fixation-break rate ----
nexttile;  hold on;  letter(1);
v = FB.rate(FB.use, [1 3 2]);  ns = size(v, 1);    % stored as RB, AB, neutral
bars_with_dots(v, cB, ns, true);
set(gca, 'XTick', 1:3, 'XTickLabel', {'RB', 'Neutral', 'AB'});
ylabel('Fixation-break rate');
if FB.p_F < 0.001, pf = 'p < 0.001'; else, pf = sprintf('p = %.3f', FB.p_F); end
title({sprintf('n = %d sessions (neutral: %d)', ns, sum(~isnan(v(:, 2)))), sprintf('F(%d,%d) = %.2f, %s', FB.df1, FB.df2, FB.F_block, pf)}, 'FontWeight', 'normal', 'FontSize', 9);

% ---- B: pupil diameter before S2 ----
nexttile;  hold on;  letter(2);
v = PU.pre_block(PU.use, [1 3 2]);  ns = size(v, 1);
bars_with_dots(v, cB, ns, false);
set(gca, 'XTick', 1:3, 'XTickLabel', {'RB', 'Neutral', 'AB'});
ylabel('Pupil diameter before S2 (z-score)');
if PU.p_F_pre < 0.001, pf = 'p < 0.001'; else, pf = sprintf('p = %.3f', PU.p_F_pre); end
title({sprintf('n = %d sessions (neutral: %d)', ns, sum(~isnan(v(:, 2)))), sprintf('F(%d,%d) = %.2f, %s', PU.df1_pre, PU.df2_pre, PU.F_pre, pf)}, 'FontWeight', 'normal', 'FontSize', 9);

% ---- C: pupil response to S2 ----
nexttile;  hold on;  letter(3);
ok = PU.use & ~isnan(PU.resp_exp) & ~isnan(PU.resp_unexp);
v = [PU.resp_exp(ok), PU.resp_unexp(ok)];  ns = size(v, 1);
bars_with_dots(v, cE, ns, false);
set(gca, 'XTick', 1:2, 'XTickLabel', {'Expected', 'Unexpected'});
ylabel('Pupil response to S2 (z-score units)');
if PU.p_resp_eu < 0.001, ps = 'p < 0.001'; else, ps = sprintf('p = %.3f', PU.p_resp_eu); end
title({sprintf('n = %d sessions', ns), ps}, 'FontWeight', 'normal', 'FontSize', 9);

%% ======================================================================
% Local functions

function bars_with_dots(v, cols, ns, as_bar)
% Session dots joined by thin lines, and the mean +- SEM per condition:
% a bar with a black error bar if as_bar, otherwise a filled circle with
% coloured error bars drawn on top of the dots.
nb = size(v, 2);
rng(1);  jit = (rand(ns, 1) - 0.5) * 0.26;       % same jitter for all conditions of a session
for k = 1:ns
    ok = ~isnan(v(k, :));
    plot(find(ok) + jit(k), v(k, ok), '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
end
if as_bar
    for j = 1:nb
        m = mean(v(:, j), 'omitnan');  nj = sum(~isnan(v(:, j)));
        bar(j, m, 0.32, 'FaceColor', cols(j, :), 'EdgeColor', 'none', 'FaceAlpha', 1);
        errorbar(j, m, std(v(:, j), 'omitnan') / sqrt(nj), 'k', 'LineWidth', 1, 'CapSize', 6);
    end
end
for j = 1:nb
    plot(j + jit, v(:, j), 'o', 'MarkerSize', 4, 'MarkerFaceColor', [0.65 0.65 0.65], 'MarkerEdgeColor', 'none');
end
if ~as_bar
    for j = 1:nb                                 % mean +- SEM at z = 1, above the data points (z = 0)
        m = mean(v(:, j), 'omitnan');  se = std(v(:, j), 'omitnan') / sqrt(sum(~isnan(v(:, j))));
        line([j j], [m - se, m + se], [1 1], 'Color', cols(j, :), 'LineWidth', 2.2);
        line([j - 0.1 j + 0.1], [m - se m - se], [1 1], 'Color', cols(j, :), 'LineWidth', 2.2);
        line([j - 0.1 j + 0.1], [m + se m + se], [1 1], 'Color', cols(j, :), 'LineWidth', 2.2);
        plot3(j, m, 1, 'o', 'MarkerSize', 9, 'MarkerFaceColor', cols(j, :), 'MarkerEdgeColor', 'w', 'LineWidth', 1);
    end
    set(gca, 'SortMethod', 'depth');  view(2);
end
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 10);
xlim([0.4 nb + 0.6]);
end