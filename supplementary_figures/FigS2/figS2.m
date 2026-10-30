% ======================================================================
% Fig S2. Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.

% ======================================================================

% Supplementary Fig. S2: cross-validated RSM, block order and drift control.
% This script only draws the figures. The numbers come from figS2_data.mat,
% which figS2_analysis.m creates.
%
%   Part 1  Cross-validated RSM of IT and vlPFC (all sessions)
%   Part 2  RSMs of the sessions with RB first and with AB first
%           (IT and vlPFC)
%   Part 3  Drift control, one row per area, three panels each:
%     A  Relative variance (%) of block and of drift for a linear drift.
%        For each neuron the variance explained by the block and by the
%        drift regressor is split by Shapley values (block entered first
%        and drift second, and the other way round, averaged), so the two
%        bars add up to 100%. Bars show the mean across neurons.
%     B  Relative variance (%) of the block for each drift shape (linear,
%        a slope per block, saturating with three time constants)
%     C  Within-block profile of the response (the shape of the drift):
%        mean change of the z-scored response over the block, sign aligned
%        to each neuron's trend (trend from odd trials, profile from even
%        trials), mean +- SEM across neurons
%
% Dots in A and B are single neurons. Error bars are the SEM across
% neurons. Stars in A and B mark a two-sided signed-rank test across
% neurons against zero (*** p < 0.001).
%
% The RSMs show the raw cross-validated squared distance (cv-d2; 0 =
% identical, red; larger = more different, blue). The diagonal (a stimulus
% with itself) is not one of the 780 pairs used in the statistics and is
% drawn as 0. Panels of the same area share one colour range. The panel
% titles give the partial Spearman correlation of the cross-validated RSM
% with the block and category models and the one-sided permutation p. For
% the block-order figure they give the context | category correlation of
% each group, the difference between the groups with its permutation p,
% and the similarity of the two RSMs with its permutation p.
%
% Input:  figS2_data.mat (variables R2, R3a, R3b, R3c, areas, cfg)
% Output: the figure windows

clc; clear; close all;
load('figS2_data.mat', 'R2', 'R3a', 'R3b', 'R3c', 'areas', 'cfg');

plot_cv_rsm(R2, areas);
plot_order_rsm(R3a, areas);
plot_drift(R3b, R3c, areas, cfg);

%% ======================================================================
% Local functions

function plot_cv_rsm(R2, areas)
% Cross-validated RSM of each area.
nA = numel(areas);
figure('Color', 'w', 'Position', [60 60 560 * nA 600]);
for a = 1:nA
    r = R2{a};
    subplot(1, nA, a);
    draw_rsm(r.rsm, r.pairIdx, prctile(r.rsm, [2 98]), true);
    title({sprintf('%s: RSM (%d neurons)', areas{a}, r.nN), 'cv-d^2, a.u.', ...
        sprintf('context | category: partial rho = %.3f, p %s', r.obs(1), fmt_p(r.p(1))), ...
        sprintf('category | context: partial rho = %.3f, p %s', r.obs(2), fmt_p(r.p(2)))}, 'FontSize', 9);
    panel_letter(char(64 + a));
end
end

function plot_order_rsm(R3a, areas)
% RSMs of the sessions with RB first and with AB first.
nA = numel(areas);
nm = {'RB first', 'AB first'};
figure('Color', 'w', 'Position', [60 60 1100 540 * nA]);
for a = 1:nA
    r = R3a{a};
    cl = prctile([r.rsm_g1; r.rsm_g2], [2 98]);
    ys = {r.rsm_g1, r.rsm_g2};
    k = 2;                                            % cross-validated distance
    for g = 1:2
        subplot(nA, 2, (a - 1) * 2 + g);
        draw_rsm(ys{g}, r.pairIdx, cl, true);
        title({sprintf('%s: RSM, %s', areas{a}, nm{g}), sprintf('%d sessions, %d neurons; cv-d^2, a.u.', r.nsess(g), r.nnrn(g)), ...
            sprintf('context | category: partial rho = %.3f', r.ordCtx(k, g)), ...
            sprintf('RB vs AB first: difference %.3f, p %s; RSM similarity rho = %.3f, p %s', ...
            r.ordCtx(k, 1) - r.ordCtx(k, 2), fmt_p(r.ctxP(k)), r.ordObs(k), fmt_p(r.ordP(k)))}, 'FontSize', 9);
        panel_letter(char(64 + (a - 1) * 2 + g));
    end
end
end

function plot_drift(R3b, R3c, areas, cfg)
% Drift control: relative variance of block and drift (Shapley), block by
% drift shape, and the within-block profile of the response.
cB = [0.20 0.40 0.80];  cR = [0.15 0.60 0.35];
nA = numel(areas);
rng(1);                                              % fixes the jitter of the dots
figure('Color', 'w', 'Position', [60 60 1650 430 * nA]);
for a = 1:nA
    r = R3b{a};  S = numel(r.sn);
    sh = 100 * r.nmean;                              % block: mean over neurons of the per-neuron relative variance (%)
    sd = 100 * r.nse;                                % SEM across neurons

    % A: block and drift, linear drift
    subplot(nA, 3, (a - 1) * 3 + 1);  hold on;
    vals = [sh(1), 100 - sh(1)];
    cols = [cB; cR];
    nsh = 100 * r.nsh(:, 1);                         % per-neuron block share (linear drift)
    dv = {nsh, 100 - nsh};
    pA = [r.p_blk(1), r.p_drf(1)];
    for c = 1:2
        bar(c, vals(c), 0.6, 'FaceColor', cols(c, :), 'EdgeColor', 'none');
        dots_n(dv{c}, c);
        errorbar(c, vals(c), sd(1), 'k', 'LineStyle', 'none', 'CapSize', 6, 'LineWidth', 1.5);
        text(c, 104, stars_of(pA(c)), 'HorizontalAlignment', 'center', 'FontSize', 12);
    end
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Block', 'Drift'}, 'FontSize', 9);
    ylabel('Relative variance (%)');  ylim([0 112]);
    title({sprintf('%s: block and drift (linear drift)', areas{a}), ...
        sprintf('block %.0f%% +- %.0f%% (mean +- SEM, %d neurons)', sh(1), sd(1), r.N)}, 'FontSize', 9);
    box off;  set(gca, 'TickDir', 'out');
    panel_letter(char(64 + (a - 1) * 3 + 1));

    % B: block for every drift shape
    subplot(nA, 3, (a - 1) * 3 + 2);  hold on;
    for s = 1:S
        bar(s, sh(s), 0.7, 'FaceColor', cB, 'EdgeColor', 'none');
        dots_n(100 * r.nsh(:, s), s);
        errorbar(s, sh(s), sd(s), 'k', 'LineStyle', 'none', 'CapSize', 6, 'LineWidth', 1.5);
        text(s, 104, stars_of(r.p_blk(s)), 'HorizontalAlignment', 'center', 'FontSize', 12);
    end
    lab = {'linear', 'block slopes'};
    for s = 3:S, lab{s} = sprintf('sat. %s', regexprep(r.sn{s}, '\D', '')); end
    set(gca, 'XTick', 1:S, 'XTickLabel', lab, 'FontSize', 8);
    ylabel('Block relative variance (%)');  ylim([0 112]);
    title({sprintf('%s: block by drift shape', areas{a}), 'sat. = saturating, time constant in trials'}, 'FontSize', 9);
    box off;  set(gca, 'TickDir', 'out');
    panel_letter(char(64 + (a - 1) * 3 + 2));

    % C: within-block profile of the response (the shape of the drift)
    subplot(nA, 3, (a - 1) * 3 + 3);  hold on;
    draw_profile(R3c{a}, areas{a}, cfg);
    panel_letter(char(64 + (a - 1) * 3 + 3));
end
end

function s = stars_of(p)
% Significance label for a p-value (n.s. if p >= 0.05).
if p < 0.001, s = '***'; elseif p < 0.01, s = '**'; elseif p < 0.05, s = '*'; else, s = 'n.s.'; end
end

function dots_n(v, x)
% One light grey dot per neuron, jittered horizontally around x.
v = v(isfinite(v));
plot(x + 0.3 * (rand(size(v)) - 0.5), v, 'o', 'MarkerSize', 2, 'MarkerFaceColor', [0.9 0.9 0.9], ...
    'MarkerEdgeColor', 'none');
end

function draw_profile(r, area, cfg)
% Within-block profile of the response (mean +- SEM across neurons) with
% the linear and saturating fits.
cols = [0.20 0.40 0.80; 0.85 0.30 0.30];
x = 1:cfg.nbin;
hh = gobjects(1, 2);
for b = 1:2
    errorbar(x + (b - 1.5) * 0.08, r.m(b, :), r.s(b, :), 'o-', 'Color', cols(b, :), 'MarkerFaceColor', cols(b, :), ...
        'LineWidth', 1.5, 'CapSize', 4);
    hh(b) = plot(NaN, NaN, 'o-', 'Color', cols(b, :), 'MarkerFaceColor', cols(b, :));   % legend handle
end
plot(x, r.fits(3).lin, 'k--', 'LineWidth', 1);
plot(x, r.fits(3).sat, 'k-', 'LineWidth', 1);
plot([0.5 cfg.nbin + 0.5], [0 0], ':', 'Color', [0.5 0.5 0.5]);
xlim([0.5 cfg.nbin + 0.5]);
set(gca, 'XTick', x, 'XTickLabel', arrayfun(@(k) sprintf('%d', round((k - 0.5) * cfg.block_trials / cfg.nbin)), x, 'UniformOutput', false));
xlabel('Trial in block (bin centre)');  ylabel('Response change (SD)');
legend(hh, {'RB', 'AB'}, 'Box', 'off', 'FontSize', 8, 'Location', 'northwest');
title({sprintf('%s: within-block profile (N = %d)', area, r.N), ...
    sprintf('RB+AB: linear R^2 %.2f; saturating R^2 %.2f (tau %.0f)', r.fits(3).r2lin, r.fits(3).r2sat, r.fits(3).tau)}, 'FontSize', 9);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 9);
end

function draw_rsm(y, pairIdx, clim_, with_cb)
% 40 x 40 RSM (RB faces, RB houses, AB faces, AB houses) from the vector of
% pairs. Display only: the raw cross-validated squared distance (cv-d^2 =
% -y), 0 = identical (red), larger = more different (blue). The statistics
% use the vector y (-cv-d^2) and are unchanged. The diagonal is not one of
% the 780 pairs; it is drawn as 0 (red) for display only.
y = -y;  clim_ = sort(-clim_);
M = nan(40);  M(pairIdx) = y;  M = triu(M, 1) + triu(M, 1)';  M(1:41:end) = 0;
imagesc(M, 'AlphaData', ~isnan(M));  hold on;
set(gca, 'Color', 'w', 'YDir', 'reverse');  colormap(gca, flipud(turbo));  caxis(clim_);
if with_cb, colorbar; end
plot([20.5 20.5], [0.5 40.5], 'k-', 'LineWidth', 1.5);  plot([0.5 40.5], [20.5 20.5], 'k-', 'LineWidth', 1.5);
for c = [10.5 30.5]
    plot([c c], [0.5 40.5], 'k:');  plot([0.5 40.5], [c c], 'k:');
end
lbl = {'RB face', 'RB house', 'AB face', 'AB house'};
set(gca, 'XTick', [5.5 15.5 25.5 35.5], 'XTickLabel', lbl, 'XTickLabelRotation', 45, ...
    'YTick', [5.5 15.5 25.5 35.5], 'YTickLabel', lbl);
axis image;  box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);
end

function s = fmt_p(p)
% p-value as text, without the leading "p" (used as "p %s").
if isnan(p), s = 'NaN'; elseif p < 0.001, s = '< 0.001'; else, s = sprintf('= %.3f', p); end
end

function panel_letter(l)
% Bold panel letter at the upper left of the current axes.
text(-0.22, 1.18, l, 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold', 'Clipping', 'off');
end