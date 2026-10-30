% ======================================================================
% Fig S3. Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.

% ======================================================================

%% figS3_plot.m
% Supplementary Fig. S3: block schedule of the sessions and generalization
% of the RSA block-context result.

%   A  Block schedule of every session (rows), block type along the
%      session in trials, grouped by monkey and sorted by block order
%   B  Number of sessions with RB, AB and N in each position of the
%      session, by monkey
%   C  RSA block-context fit (category partialled out) in 500 random
%      session split-halves; the red line is the fit on all sessions
%   D  The same fit by block position (RB or AB as 1st, 2nd or 3rd block of
%      the session) and by monkey. The black line is the fit on all
%      sessions of the group, the dotted line the 95th percentile of the
%      shuffled-label null, the grey dots refits on random 80% subsamples
%      of the sessions, * p < 0.05 and n is the number of neurons.
%
% Input:  figS3_data.mat (variables raster, bin, max_len, sm, u_m,
%         mname, cnt, full, part_halves, frac_both, n_splits, res, sub_fit,
%         grp_names)
% Output: the figure window

clc; clear; close all;
load('figS3_data.mat');
rng(1);                                      % fixes the jitter of the dots in D

short = {'RB', 'AB', 'N'};
col   = [0.85 0.20 0.20; 0.20 0.40 0.80; 0.70 0.70 0.70];     % RB, AB, N
mcol  = [0.55 0.35 0.75; 0.30 0.65 0.40];                     % monkeys (purple, green)
n_s = size(raster, 1);

figure('Color', 'w', 'Position', [50 50 1400 800]);
tiledlayout(2, 6, 'TileSpacing', 'compact', 'Padding', 'compact');

%% A: block schedule
nexttile(1, [1 3]);
imagesc((1:size(raster, 2)) * bin, 1:n_s, raster);
colormap(gca, [1 1 1; col]);  caxis([0 3]);
set(gca, 'YDir', 'normal');
hold on;
for k = u_m(1:end - 1)
    yline(sum(sm <= k) + 0.5, 'k-', 'LineWidth', 1.5);
end
for k = u_m
    text(max_len * 0.995, mean(find(sm == k)), mname{k}, 'Rotation', 90, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 9);
end
for k = 1:3, plot(nan, nan, 's', 'MarkerFaceColor', col(k, :), 'MarkerEdgeColor', 'none', 'MarkerSize', 9); end
legend(short, 'Location', 'southoutside', 'Orientation', 'horizontal');  legend boxoff;
xlabel('Trial in session');  ylabel('Session');
title('A. Block schedule of each session');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);

%% B: sessions with RB, AB, N in each position of the session
nexttile(4, [1 3]);  hold on;
xs = [1 2 3, 5 6 7, 9 10 11];                % three bars (RB, AB, N) per position
cm = zeros(9, numel(u_m));
for q = 1:3
    for b = 1:3
        cm((q - 1) * 3 + b, :) = squeeze(cnt(q, b, :))';
    end
end
hb = bar(xs, cm, 'stacked', 'BarWidth', 0.8, 'EdgeColor', 'none');
for k = 1:numel(u_m), hb(k).FaceColor = mcol(k, :); end
for j = 1:9
    text(xs(j), sum(cm(j, :)), num2str(sum(cm(j, :))), 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'FontSize', 9);
    base = 0;                                % count of each monkey inside its segment
    for k = 1:numel(u_m)
        if cm(j, k) > 0
            text(xs(j), base + cm(j, k) / 2, num2str(cm(j, k)), 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'Color', 'w', 'FontSize', 9);
        end
        base = base + cm(j, k);
    end
end
ymax = max(sum(cm, 2)) * 1.15;
ylim([0 ymax]);
set(gca, 'XTick', xs, 'XTickLabel', repmat(short, 1, 3));
for q = 1:3
    text(mean(xs((q - 1) * 3 + (1:3))), -0.13 * ymax, sprintf('Position %d', q), ...
        'HorizontalAlignment', 'center', 'Clipping', 'off', 'FontSize', 10);
end
ylabel('Sessions');  title('B. Block type in each position of the session');
legend(hb, mname(u_m), 'Location', 'northeast');  legend boxoff;
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);

%% C: session split-halves
nexttile(7, [1 2]);  hold on;
histogram(part_halves, 30, 'FaceColor', [0.45 0.45 0.45], 'EdgeColor', 'none');
xline(full.partial, 'r-', 'LineWidth', 2);
xlabel('Block fit, partial \rho');  ylabel('Half-sample fits');
title('C. Session split-halves');
text(0.02, 0.95, sprintf('Significant in both halves:\n%.0f%% of %d splits', 100 * frac_both, n_splits), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 9);
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);

%% D: subsets of sessions
nexttile(9, [1 4]);  hold on;
for g = 1:numel(res)
    if isnan(res(g).partial), continue; end
    bar(g, res(g).partial, 0.6, 'FaceColor', [0.85 0.85 0.85], 'EdgeColor', 'none');
    % Small jittered dots in one flat light colour with no edge, so that
    % overlapping dots do not get darker
    v = sub_fit{g};  v = v(~isnan(v));
    scatter(g + 0.22 * (rand(size(v)) - 0.5) * 2, v, 8, [0.55 0.65 0.90], 'filled', ...
        'MarkerEdgeColor', 'none');
    plot(g + [-0.3 0.3], res(g).partial * [1 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);
    plot(g + [-0.3 0.3], res(g).null95 * [1 1], 'k:', 'LineWidth', 1.5);
    if res(g).p < 0.05
        text(g, res(g).partial, '*', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 14);
    end
    text(g, 0, sprintf('n=%d', res(g).n), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 8);
end
set(gca, 'XTick', 1:numel(res), 'XTickLabel', grp_names);
xtickangle(30);
ylabel('Block fit, partial \rho');
title('D. Block fit by block position and by monkey (bar/line = all sessions; dotted = null 95th pct; points = 80% session subsamples)');
box off;  set(gca, 'TickDir', 'out', 'FontSize', 10);