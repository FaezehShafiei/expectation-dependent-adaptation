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
% Fig. S14: Fig. 4 for each monkey separately (IT).
% It also needs ndass_confid_niceplot.m and
% ndass_smooth.m on the MATLAB path.
%
% Rows 1-2: Monkey F (A-C single units, D-F field potentials); rows 3-4: Monkey V.
%   A, D  Cohen's d among expected vs unexpected trials, one dot per neuron / site, regression line and correlation
%   B, E  Cohen's d for expected, neutral and unexpected trials, for neurons / sites with a positive (blue) or a
%         negative (red) effect on expected trials. Points: single neurons (transparent) and the mean +- SEM.
%         Brackets mark paired t-tests between expected and neutral and between neutral and unexpected trials,
%         separately for each group (* p < 0.05, ** p < 0.01, *** p < 0.001, n.s. = not significant)
%   C, F  time course of the correlation (from the onset of the second stimulus), with an inset comparing the
%         baseline and the response window
%
% Input:  figS14_data.mat (variables spike_bymonkey, lfp_bymonkey, time_spike, time_lfp, monkeys)
% Output: the figure window

clc; clear; close all;
load('figS14_data.mat');

ITC_c = [0, 0.5020, 0];
monkey_labels = {'Monkey F', 'Monkey V'};
labels = {'Expected', 'Neutral', 'Unexpected'};

figure('Color', 'w', 'Position', [50 50 1400 1500]);

for m = monkeys
    base = (m - 1) * 2 * 3;                  % 0 for monkey F, 6 for monkey V
    sd = spike_bymonkey(m);
    ld = lfp_bymonkey(m);

    %% A: single units, expected vs unexpected
    subplot(4, 3, base + 1);  hold on;
    x = sd.cohen_d_rep';
    y = sd.cohen_d_alt';
    scatter(x, y, 10, 'o', 'MarkerFaceColor', [0.2 0.6 0.8], 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    p = polyfit(x, y, 1);
    xfit = linspace(min(x), max(x), 100);
    plot(xfit, polyval(p, xfit), 'r-', 'LineWidth', 2);
    [r_a, pval_a] = corr(x, y);
    text(min(x), max(y), sprintf('r = %.2f, %s', r_a, p_str(pval_a)), ...
        'FontSize', 10, 'FontWeight', 'bold', 'VerticalAlignment', 'top');
    xlabel('Cohen''s d, Expected');  ylabel('Cohen''s d, Unexpected');
    title(sprintf('%s - A (single units)', monkey_labels{m}));
    axis square;  set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 10, 'LineWidth', 1);

    %% B: single units, expected / neutral / unexpected
    subplot(4, 3, base + 2);  hold on;
    pos = sd.cohen_d_rep > 0;  neg = sd.cohen_d_rep < 0;
    data_pos = {sd.cohen_d_rep(pos), sd.cohen_d_rnd(pos), sd.cohen_d_alt(pos)};
    data_neg = {sd.cohen_d_rep(neg), sd.cohen_d_rnd(neg), sd.cohen_d_alt(neg)};
    for k = 1:3
        draw_group(k + 0.1, data_pos{k}, [0 0 1]);
        draw_group(k - 0.1, data_neg{k}, [1 0 0]);
    end
    draw_brackets(data_pos, data_neg);
    axis square;  xlim([0.5 3.5]);
    set(gca, 'XTick', 1:3, 'XTickLabel', labels, 'FontSize', 7, 'LineWidth', 0.5, 'TickDir', 'out', 'Box', 'off');
    ylabel('Cohen''s d', 'FontSize', 8);
    title(sprintf('%s - B', monkey_labels{m}));

    %% C: single units, time course and baseline vs response
    subplot(4, 3, base + 3);  hold on;
    ndass_confid_niceplot(sd.r_boot, time_spike, 5, ITC_c, 0.3);
    ylabel('Correlation');  xlabel('Time from 2nd stim. (ms)');  xlim([-50 400]);
    plot([0 0], ylim, 'k', 'LineWidth', 1);
    yl = ylim;
    fill([0 100 100 0], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    set(gca, 'Box', 'off', 'TickDir', 'out');
    title(sprintf('%s - C', monkey_labels{m}));

    ax_pos = get(gca, 'Position');
    axes('Position', [ax_pos(1) + ax_pos(3) * 0.65, ax_pos(2) + ax_pos(4) * 0.65, ax_pos(3) * 0.3, ax_pos(4) * 0.3]);  hold on;
    means = [nanmean(sd.r_base), nanmean(sd.r_resp)];
    sems  = [nanstd(sd.r_base),  nanstd(sd.r_resp)];
    bar(1:2, means);  errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Base', 'Resp'}, 'FontSize', 6);
    title(p_str(sd.p_baseresp), 'FontSize', 6);

    %% D: field potentials, expected vs unexpected
    subplot(4, 3, base + 4);  hold on;
    x = ld.cohen_d_rep_static;
    y = ld.cohen_d_alt_static;
    scatter(x, y, 10, 'o', 'MarkerFaceColor', [0.2 0.6 0.8], 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    p = polyfit(x, y, 1);
    xfit = linspace(min(x), max(x), 100);
    plot(xfit, polyval(p, xfit), 'r-', 'LineWidth', 2);
    [r_d, pval_d] = corr(x, y);
    text(min(x), max(y), sprintf('r = %.2f, %s', r_d, p_str(pval_d)), ...
        'FontSize', 10, 'FontWeight', 'bold', 'VerticalAlignment', 'top');
    xlabel('Effect, Expected');  ylabel('Effect, Unexpected');
    title(sprintf('%s - D (LFP)', monkey_labels{m}));
    axis square;  set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 10, 'LineWidth', 1);

    %% E: field potentials, expected / neutral / unexpected
    subplot(4, 3, base + 5);  hold on;
    x = ld.cohen_d_rep_static;  y = ld.cohen_d_alt_static;  z = ld.cohen_d_rnd_static;
    data_pos = {x(x > 0), z(x > 0), y(x > 0)};
    data_neg = {x(x < 0), z(x < 0), y(x < 0)};
    for k = 1:3
        draw_group(k + 0.1, data_pos{k}, [0 0 1]);
        draw_group(k - 0.1, data_neg{k}, [1 0 0]);
    end
    draw_brackets(data_pos, data_neg);
    axis square;  xlim([0.5 3.5]);
    set(gca, 'XTick', 1:3, 'XTickLabel', labels, 'FontSize', 7, 'LineWidth', 0.5, 'TickDir', 'out', 'Box', 'off');
    ylabel('Cohen''s d', 'FontSize', 8);
    title(sprintf('%s - E', monkey_labels{m}));

    %% F: field potentials, time course and baseline vs response
    subplot(4, 3, base + 6);  hold on;
    ndass_confid_niceplot(ld.r_boot, time_lfp, 20, ITC_c, 0.3);
    ylabel('Correlation');  xlabel('Time from 2nd stim. (ms)');  xlim([-50 400]);
    plot([0 0], ylim, 'k', 'LineWidth', 1);
    yl = ylim;
    fill([0 100 100 0], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    set(gca, 'Box', 'off', 'TickDir', 'out');
    title(sprintf('%s - F', monkey_labels{m}));

    ax_pos = get(gca, 'Position');
    axes('Position', [ax_pos(1) + ax_pos(3) * 0.65, ax_pos(2) + ax_pos(4) * 0.65, ax_pos(3) * 0.3, ax_pos(4) * 0.3]);  hold on;
    means = [nanmean(ld.r_base), nanmean(ld.r_resp)];
    sems  = [nanstd(ld.r_base),  nanstd(ld.r_resp)];
    bar(1:2, means);  errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1);
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Base', 'Resp'}, 'FontSize', 6);
    title(p_str(ld.p_baseresp), 'FontSize', 6);
end

%% ======================================================================
% Local functions

function draw_group(xk, v, col)
% Single values (transparent dots), their mean and SEM at position xk.
scatter(xk * ones(size(v)), v, 6, 'MarkerFaceColor', col, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.25);
m  = mean(v);
se = std(v) / sqrt(numel(v));
errorbar(xk, m, se, 'k', 'LineWidth', 1, 'CapSize', 6);
scatter(xk, m, 25, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
end

function draw_brackets(data_pos, data_neg)
% Paired t-tests between neighbouring conditions, drawn as brackets in the
% colour of the group (blue: positive on expected trials, red: negative).
% Each cell holds expected, neutral and unexpected, from the same neurons.
yl = ylim;  rng = diff(yl);
tick = 0.03 * rng;
ylim([yl(1) - 0.30 * rng, yl(2) + 0.30 * rng]);
top = yl(2);  bot = yl(1);

bracket(1.1, 2.1, top + 0.15 * rng, +1, data_pos{1}, data_pos{2}, [0 0 1], tick);   % blue, expected vs neutral
bracket(2.1, 3.1, bot - 0.05 * rng, -1, data_pos{2}, data_pos{3}, [0 0 1], tick);   % blue, neutral vs unexpected
bracket(1.9, 2.9, top + 0.05 * rng, +1, data_neg{2}, data_neg{3}, [1 0 0], tick);   % red, neutral vs unexpected
bracket(0.9, 1.9, bot - 0.15 * rng, -1, data_neg{1}, data_neg{2}, [1 0 0], tick);   % red, expected vs neutral
end

function bracket(x1, x2, y, dir, a, b, col, tick)
% One bracket between x1 and x2 at height y (dir = +1 above the data, -1
% below it) with the paired t-test result between a and b as stars.
[~, p] = ttest(a, b);
line([x1 x1 x2 x2], [y - dir * tick, y, y, y - dir * tick], 'Color', col, 'LineWidth', 0.75);
text(mean([x1 x2]), y, stars_of(p), 'Color', col, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 9);
end

function s = stars_of(p)
% Significance label for a p-value (n.s. if p >= 0.05).
if p < 0.001, s = '***';
elseif p < 0.01, s = '**';
elseif p < 0.05, s = '*';
else, s = 'n.s.';
end
end

function s = p_str(p)
% p-value as text. Never printed as p = 0: for bootstrap p-values the
% smallest possible value is 1/n_boot, which is also shown as p < 0.001.
if p <= 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end