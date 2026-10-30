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
%
%  Fig. S12: robustness of the expected-vs-unexpected correlation of
% Fig. 4 and interaction of expectation with adaptation.
% 
%
% Row 1: robustness of the expected-vs-unexpected correlation
%   A  single units: scatter of Fig. 4A; red = points with Cook's D > 4/n; black line = fit to all, red dashed = fit without them
%   B  LFP: same for Fig. 4D
%   C  worst-case removal: repeatedly remove the unit whose removal makes r least negative (x: % of units removed);
%      filled = p < 0.05, open = p >= 0.05; single units blue, LFP orange
%   D  95% bootstrap CIs over units of Pearson r and Spearman rho (10000 draws)
% Row 2: adaptation x expectation, late window (100-200 ms after response onset)
%   E, F  mean +- SEM across neurons of repeated / alternated S2, expected (blue) and unexpected (orange), after subtracting each
%         neuron's mean over the four conditions; E adaptation index, F S2 firing rate (spikes/s). Title: p of expectation (E),
%         adaptation (A) and interaction (I), paired t-tests
%   G, H  differences between conditions (simple effects and interaction; mean +- SEM, t-test p next to each bar) for the
%         adaptation index (G) and the S2 firing rate (H); interaction bar in dark grey
%
% Input:  figS12_data.mat (variables RB and IX)
% Output: the figure window

clc; clear; close all;
load('figS12_data.mat', 'RB', 'IX');
cB = [0.20 0.45 0.75];  cO = [0.85 0.45 0.10];  cR = [0.85 0.15 0.15];  cG = [0.55 0.65 0.75];
figure('Color', 'w', 'Position', [30 30 1500 700]);
tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
L = 0;
letter = @(k) text(-0.2, 1.12, char('A' + k - 1), 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 13);

%% Row 1: robustness of the correlation
for d = 1:2                                              % A, B: scatters
    o = RB.(sprintf('d%d', d));
    nexttile;  hold on;  L = L + 1;  letter(L);
    scatter(o.x(~o.flag_cook), o.y(~o.flag_cook), 12, cG, 'filled', 'MarkerEdgeColor', 'none');
    scatter(o.x(o.flag_cook),  o.y(o.flag_cook),  16, cR, 'filled', 'MarkerEdgeColor', 'none');
    xf = linspace(min(o.x), max(o.x), 100);
    p1 = polyfit(o.x, o.y, 1);  plot(xf, polyval(p1, xf), 'k-', 'LineWidth', 1.6);
    k = ~o.flag_cook;  p2 = polyfit(o.x(k), o.y(k), 1);  plot(xf, polyval(p2, xf), '--', 'Color', cR, 'LineWidth', 1.6);
    title(sprintf('%s\nr = %.2f, rho = %.2f\nwithout %d flagged: r = %.2f', o.name, o.r, o.rho, o.n_cook, o.r_nocook), 'FontWeight', 'normal', 'FontSize', 8);
    xlabel('Repetition effect, expected');  ylabel('Repetition effect, unexpected');  axis square;  box off;  set(gca, 'TickDir', 'out');
end

nexttile;  hold on;  L = L + 1;  letter(L);               % C: worst-case removal
col = {cB, cO};  h = gobjects(1, 2);
for d = 1:2
    o = RB.(sprintf('d%d', d));
    kk = 1:numel(o.rk);  xk = 100 * kk / o.n;
    h(d) = plot([0 xk], [o.r; o.rk(:)], '-', 'Color', col{d}, 'LineWidth', 1.4);
    sig = o.pk < 0.05;
    plot(xk(sig),  o.rk(sig),  'o', 'MarkerFaceColor', col{d}, 'MarkerEdgeColor', 'none', 'MarkerSize', 4);
    plot(xk(~sig), o.rk(~sig), 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', col{d}, 'MarkerSize', 4);
end
yline(0, 'k:');
legend(h, {RB.d1.name, RB.d2.name}, 'Box', 'off', 'Location', 'southeast', 'FontSize', 8);
title(sprintf('Worst-case removal\n(filled: p < 0.05)'), 'FontWeight', 'normal', 'FontSize', 8);
xlabel('Units removed (%)');  ylabel('Pearson r');  box off;  set(gca, 'TickDir', 'out');

nexttile;  hold on;  L = L + 1;  letter(L);               % D: bootstrap CIs
ylab = {};  yy = 0;
for d = 1:2
    o = RB.(sprintf('d%d', d));
    vals = {o.r, o.rho};  cis = {o.ci_r, o.ci_rho};  nm = {'r', 'rho'};
    for j = 1:2
        yy = yy + 1;
        plot(cis{j}, [yy yy], '-', 'Color', col{d}, 'LineWidth', 2.5);
        plot(vals{j}, yy, 'o', 'MarkerFaceColor', col{d}, 'MarkerEdgeColor', 'none', 'MarkerSize', 7);
        ylab{yy} = sprintf('%s, %s', o.name, nm{j});
    end
end
xline(0, 'k:');
set(gca, 'YTick', 1:4, 'YTickLabel', ylab, 'YDir', 'reverse', 'TickDir', 'out');  ylim([0.5 4.5]);
title(sprintf('Bootstrap over units\n95%% CI'), 'FontWeight', 'normal', 'FontSize', 8);
xlabel('Correlation');  box off;

%% Row 2: interaction of expectation with adaptation
meas = {'AI', 'RS2'};
mlab = {'\Delta adaptation index', '\Delta S2 rate (spikes/s)'};
dlab = {'\Delta adaptation index', '\Delta S2 rate (spikes/s)'};
blab = {'Expectation | repeated', 'Expectation | alternated', 'Adaptation | expected', 'Adaptation | unexpected', 'Interaction'};
cI = [0.30 0.30 0.30];                                   % bar colour of the interaction
for m = 1:2                                              % E, F: interaction plots
    o = IX.(meas{m}).late;
    c = o.cells - mean(o.cells, 2);                      % columns: RE RU AE AU
    mu = mean(c, 1);  se = std(c, 0, 1) / sqrt(o.n);
    nexttile;  hold on;  L = L + 1;  letter(L);
    errorbar([1 2], [mu(1) mu(3)], [se(1) se(3)], '-o', 'Color', cB, 'MarkerFaceColor', cB, 'LineWidth', 1.6, 'CapSize', 7);
    errorbar([1 2], [mu(2) mu(4)], [se(2) se(4)], '-o', 'Color', cO, 'MarkerFaceColor', cO, 'LineWidth', 1.6, 'CapSize', 7);
    set(gca, 'XTick', [1 2], 'XTickLabel', {'Repeated', 'Alternated'}, 'TickDir', 'out');
    xlim([0.5 2.5]);  box off;  ylabel(mlab{m});
    S = o.S;
    title(sprintf('Late window (n = %d)\nE %s, A %s, I %s', o.n, pshort(S.p(2)), pshort(S.p(1)), pshort(S.p(3))), 'FontWeight', 'normal', 'FontSize', 8);
    if m == 1, legend({'Expected', 'Unexpected'}, 'Box', 'off', 'Location', 'southwest', 'FontSize', 8); end
end
bshort = {'Exp | rep', 'Exp | alt', 'Adapt | exp', 'Adapt | unexp', 'Interaction'};
for m = 1:2                                              % G, H: simple effects and interaction
    S = IX.(meas{m}).late.S;  idx = [4 5 6 7 3];
    mu = S.mean(idx);  se = S.sem(idx);
    nexttile;  hold on;  L = L + 1;  letter(L);
    b = bar(1:5, mu, 0.6, 'FaceColor', 'flat', 'EdgeColor', 'none');
    b.CData = [repmat(cG, 4, 1); cI];                    % interaction bar in dark grey
    errorbar(1:5, mu, se, 'k', 'LineStyle', 'none', 'CapSize', 6, 'LineWidth', 1.6);
    yline(0, 'k-');
    lo = min([0, mu - se]);  hi = max([0, mu + se]);  pad = 0.12 * (hi - lo);
    ylim([lo - pad, hi + pad]);
    for j = 1:5                                          % t-test p above (or below, for negative bars) each bar
        if mu(j) >= 0, yt = mu(j) + se(j);  va = 'bottom'; else, yt = mu(j) - se(j);  va = 'top'; end
        text(j, yt, pshort(S.p(idx(j))), 'HorizontalAlignment', 'center', 'VerticalAlignment', va, 'FontSize', 8);
    end
    set(gca, 'XTick', 1:5, 'XTickLabel', bshort, 'TickDir', 'out');  xtickangle(35);  xlim([0.4 5.6]);
    ylabel(dlab{m});  box off;
end


%% ======================================================================
% Local functions

function s = pshort(p)
if p < 0.001, s = 'p<0.001'; else, s = sprintf('p=%.3f', p); end
end