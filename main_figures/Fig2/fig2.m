% ======================================================================
% Fig2. Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et.al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.
%
% The scripts were written in MATLAB R2022a. Analysis scripts compute the
% numbers and save them as .mat files; plot scripts only draw from those
% files.

% ======================================================================

% Figure 2: representational similarity analysis (RSA) of IT and vlPFC.

%   A  IT: the representational similarity matrix (RSM), the two model
%      RSMs, and the partial correlations between the RSM and the models
%   B  IT: hierarchical clustering of the RSM
%   C, D  the same for vlPFC
%
% Bars show the partial Spearman correlation of the RSM with the block
% model (category partialled out) and with the category model (block
% partialled out). Error bars are the SD of the hierarchical bootstrap
% (sessions within monkey, then neurons within session). Stars mark the
% permutation p-value; the permutations keep the factorial design.
%
% Input:  fig2_data.mat (variables F and areas)
% Output: the figure window

clc; clear; close all;
load('fig2_data.mat', 'F', 'areas');

%% Model RSMs (1 = same block / same category)
% Stimuli 1-20 were shown in the repeating block, 21-40 in the alternating
% block; within each block the first 10 are faces and the last 10 houses.
blkLab = [ones(20, 1); 2 * ones(20, 1)];
catLab = [ones(10, 1); 2 * ones(10, 1)];
catLab = [catLab; catLab];
model_blk = double(blkLab == blkLab');
model_cat = double(catLab == catLab');

%% Figure
figure('Color', 'w', 'Position', [40 40 1700 850]);
letters = {'A', 'B'; 'C', 'D'};

for a = 1:numel(areas)
    r = F{a};
    base = 0.5 * (numel(areas) - a);        % bottom of this row, in normalised units

    % Empirical RSM
    axes('Position', [0.05, base + 0.08, 0.17, 0.34]);
    imagesc(r.rsm);
    title(sprintf('%s: empirical RSM (%d neurons)', areas{a}, r.nN), 'FontSize', 12);
    xlabel('Stimulus');  ylabel('Stimulus');
    axis square;  colormap(gca, jet);  colorbar;
    set(gca, 'TickDir', 'out', 'FontSize', 11);

    % Model RSMs
    model_axes([0.29, base + 0.27, 0.09, 0.18], model_blk, 'Block model');
    model_axes([0.29, base + 0.04, 0.09, 0.18], model_cat, 'Category model');

    % Partial correlations with the two models
    axes('Position', [0.45, base + 0.08, 0.12, 0.34]);  hold on;
    for s = 1:2
        bar(s, r.obs(s), 0.6, 'FaceColor', [0.55 0.55 0.55], 'EdgeColor', 'none');
        errorbar(s, r.obs(s), r.sd(s), 'k', 'LineStyle', 'none', 'CapSize', 6, 'LineWidth', 1.5);
        text(s, r.obs(s) + r.sd(s) + 0.03, stars_of(r.p(s)), 'HorizontalAlignment', 'center', 'FontSize', 13);
    end
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Block', 'Category'}, 'YTick', 0:0.2:1);
    xlim([0.4 2.6]);  ylim([0 1.1]);
    ylabel('Partial Spearman correlation');
    box off;  set(gca, 'TickDir', 'out', 'FontSize', 11);

    % Dendrogram
    axes('Position', [0.64, base + 0.08, 0.34, 0.34]);
    dendrogram(r.Z, 0);
    title('Hierarchical clustering (average linkage)', 'FontSize', 12);
    set(gca, 'TickDir', 'out', 'FontSize', 10);

    % Panel letters
    annotation('textbox', [0.01, base + 0.44, 0.03, 0.04], 'String', letters{a, 1}, ...
        'EdgeColor', 'none', 'FontSize', 18, 'FontWeight', 'bold');
    annotation('textbox', [0.60, base + 0.44, 0.03, 0.04], 'String', letters{a, 2}, ...
        'EdgeColor', 'none', 'FontSize', 18, 'FontWeight', 'bold');
end

%% ======================================================================
% Local functions

function model_axes(pos, M, ttl)
% Draw one model RSM as a small black-and-white matrix.
axes('Position', pos);
imagesc(M);
title(ttl, 'FontSize', 11);
axis square;  colormap(gca, flipud(gray(256)));
set(gca, 'XTick', [], 'YTick', []);
end

function s = stars_of(p)
% Significance label for a p-value (n.s. if p >= 0.05).
if p < 0.001, s = '***';
elseif p < 0.01, s = '**';
elseif p < 0.05, s = '*';
else, s = 'n.s.';
end
end