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
%
%  Fig. S10: stimulus set and neural selectivity.
% 
%
%   A  block effect for faces (purple) and houses (light blue) in four 100 ms windows after the response onset; exact p of t-tests against 0
%   B  split-half reliability of the face tuning, neurons selective for identity in colour
%   C  the same for houses
%   D  S1-S2 distance in the face tuning on alternated trials, RB vs AB
%   E  RSA with a pixel-similarity model added: partial correlations and their permutation null
% Points are mean +- SEM across neurons.
%
% Input:  figS11_data.mat
% Output: the figure window

clc; clear; close all;
load('figS11_data.mat');
alpha_sel = 0.05;  nw = numel(wlab);  nc = numel(cn);
set(groot, 'defaultAxesFontName', 'Arial', 'defaultTextFontName', 'Arial');
cF = [0.45 0.20 0.65];  cH = [0.60 0.80 0.95];  cG = [0.35 0.35 0.35];  cL = [0.80 0.80 0.80];
cR = [0.80 0.10 0.10];  cA = [0.10 0.35 0.95];  cO = [0.95 0.60 0.10];  ccat = [cF; cH];

figure('Color', 'w', 'Position', [20 20 1350 720]);
tiledlayout(2, 12, 'TileSpacing', 'compact', 'Padding', 'loose');
letter = @(k) text(-0.14, 1.08, char('A' + k - 1), 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 13);
ttl = @(s) title(s, 'FontWeight', 'normal', 'FontSize', 9);

% ---- A: block effect by category and window ----
nexttile([1 8]);  hold on;  letter(1);
M = nan(nw, nc);  S = nan(nw, nc);  off = 0.15;
for c = 1:nc
    for w = 1:nw
        v = BE(isfinite(BE(:, w, c)), w, c);  M(w, c) = mean(v);  S(w, c) = std(v) / sqrt(numel(v));
    end
end
yline(0, 'k:');
hb = gobjects(1, nc);
for c = 1:nc
    for w = 1:nw
        x = w + (c - 1.5) * 2 * off;
        errorbar(x, M(w, c), S(w, c), 'Color', ccat(c, :), 'LineStyle', 'none', 'LineWidth', 2, 'CapSize', 8);
        h = plot(x, M(w, c), 'o', 'MarkerFaceColor', ccat(c, :), 'MarkerEdgeColor', ccat(c, :), 'MarkerSize', 7);
        if w == 1, hb(c) = h; end
        if M(w, c) >= 0, text(x, M(w, c) + S(w, c), pstr(p_BE(w, c)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9);
        else, text(x, M(w, c) - S(w, c), pstr(p_BE(w, c)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 9); end
    end
end
lo = min(M(:) - S(:));  hi = max(M(:) + S(:));  pad = 0.2 * (hi - lo);
ylim([min(lo, 0) - pad, max(hi, 0) + pad]);  xlim([0.4 nw + 0.6]);
set(gca, 'XTick', 1:nw, 'XTickLabel', wlab, 'TickDir', 'out', 'Box', 'off', 'FontSize', 9);
xlabel('Time after response onset (ms)');  ylabel('Block effect');
legend(hb, {'Faces', 'Houses'}, 'Box', 'off', 'Location', 'northwest', 'FontSize', 9);
ttl(strjoin(anova_txt(~contains(anova_txt, "Cat:Win")), '; '));

% ---- B, C: reliability and selectivity ----
edges = -1:0.1:1;  ctr = edges(1:end-1) + 0.05;
for c = 1:nc
    nexttile([1 4]);  hold on;  letter(c + 1);
    isel = p_anova(:, c) < alpha_sel;  okr = isfinite(rel_sb(:, c));
    cnt = [histcounts(rel_sb(okr & ~isel, c), edges)', histcounts(rel_sb(okr & isel, c), edges)'];
    hbar = bar(ctr, cnt, 1, 'stacked', 'EdgeColor', 'w', 'LineWidth', 0.5);
    hbar(1).FaceColor = cL;  hbar(2).FaceColor = ccat(c, :);
    xline(0, 'k:');  xline(rel_med(c), 'Color', cG, 'LineStyle', '--', 'LineWidth', 1.2);
    set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 9);  xlim([-1.05 1.05]);
    xlabel(sprintf('Split-half reliability of %s tuning', lower(char(cn(c)))));  ylabel('Neurons');
    legend(hbar, {sprintf('Not selective (n = %d)', n_neurons - k_sel(c)), sprintf('Selective (n = %d)', k_sel(c))}, 'Box', 'off', 'Location', 'northwest', 'FontSize', 8);
    ttl(sprintf('Median %.2f (IQR %.2f to %.2f)', rel_med(c), rel_q(1, c), rel_q(2, c)));
end
% (panel order: B faces, C houses)

% ---- D: S1-S2 tuning distance ----
nexttile([1 3]);  hold on;  letter(4);
dots_mean(1:2, {dB(:, 1), dB(:, 2)}, [cR; cA]);
set(gca, 'XTick', 1:2, 'XTickLabel', {'RB', 'AB'});  xlim([0.4 2.6]);  ylim([1.14 1.17]);
ylabel('S1-S2 tuning distance (SD)');
title(sprintf('Alternated face trials, RB vs AB, %s', pstr(p_d_blk)), 'FontWeight', 'normal', 'FontSize', 9);

% ---- E: RSA with a pixel-similarity model ----
nexttile([1 5]);  hold on;  letter(5);
if D_done
    cols = [cO; cA; cG];  q = prctile(nullD, [2.5 97.5]);
    for k = 1:3
        patch([k-0.3 k+0.3 k+0.3 k-0.3], [q(1, k) q(1, k) q(2, k) q(2, k)], [0.88 0.88 0.88], 'EdgeColor', 'none');
        line(k + [-0.3 0.3], median(nullD(:, k)) * [1 1], 'Color', [0.55 0.55 0.55], 'LineWidth', 1);
        plot(k, obsD(k), 'o', 'MarkerSize', 10, 'MarkerFaceColor', cols(k, :), 'MarkerEdgeColor', 'w', 'LineWidth', 1);
        text(k, max(obsD(k), q(2, k)) + 0.03, pstr(pD(k)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8);
    end
    yline(0, 'k:');
    set(gca, 'XTick', 1:3, 'XTickLabel', {'Category', 'Context', 'Pixel'}, 'TickDir', 'out', 'Box', 'off', 'FontSize', 9);
    xtickangle(0);  xlim([0.4 3.6]);  ylim([min(0, min(q(1, :))) - 0.05, max([obsD, q(2, :)]) + 0.15]);
    ylabel('Partial Spearman correlation');
    title({'RSA with a pixel-similarity model', 'grey: permutation null (median, 95% range)'}, 'FontWeight', 'normal', 'FontSize', 9);
else
    axis off;  text(0.5, 0.5, 'Images not found: RSA not run', 'HorizontalAlignment', 'center', 'Units', 'normalized');
end

%% ======================================================================
% Local functions

function dots_mean(xp, G, cols)
% mean +- SEM: error bar and filled circle drawn at z = 1
for k = 1:numel(G)
    v = G{k};  v = v(isfinite(v));  m = mean(v);  se = std(v) / sqrt(numel(v));
    line([xp(k) xp(k)], [m - se, m + se], [1 1], 'Color', cols(k, :), 'LineWidth', 2.2);
    line(xp(k) + [-0.12 0.12], [m - se m - se], [1 1], 'Color', cols(k, :), 'LineWidth', 2.2);
    line(xp(k) + [-0.12 0.12], [m + se m + se], [1 1], 'Color', cols(k, :), 'LineWidth', 2.2);
    plot3(xp(k), m, 1, 'o', 'MarkerSize', 9, 'MarkerFaceColor', cols(k, :), 'MarkerEdgeColor', 'w', 'LineWidth', 1);
end
set(gca, 'SortMethod', 'depth', 'TickDir', 'out', 'Box', 'off', 'FontSize', 9);  view(2);
end

function s = pstr(p)
if isnan(p), s = 'p = NaN'; elseif p < 0.001, s = 'p < 0.001'; else, s = sprintf('p = %.3f', p); end
end