% ======================================================================
% Fig S4. Code for:
%   "Prefrontal feedback is associated with expectation-dependent
%    adaptation in inferotemporal cortex"
%   Shafiei et al. Communications Biology (under revision).
%
% This script is part of the analysis code for the paper above. We
% recorded single units and field potentials from macaque IT and vlPFC
% while monkeys viewed pairs of images in blocks with different
% repetition probabilities.

% ======================================================================


% Supplementary Fig. S4: representational similarity matrices (RSMs) of IT
% and vlPFC for each monkey.

%   A  Monkey F
%   B  Monkey V
%
% Rows are monkeys and columns are areas (IT, vlPFC). Each panel shows the
% empirical RSM, the binary block model (black = same block), and the
% Kendall tau and Spearman rho between the two.
%
% Input:  figS4_data.mat (variables M and areas)
% Output: the figure window

clc; clear; close all;
load('figS4_data.mat', 'M', 'areas');

% Monkey 1 = F and monkey 2 = V is assumed here; check that the monkey ids
% in the data match.
animal = {'Monkey F', 'Monkey V'};
% Colour range of the RSMs: rows = monkeys (F, V), columns = areas (IT, vlPFC)
rsm_clim = {[0.5 1], [0.7 1]; ...
            [0.5 1], [0.8 1]};

model = zeros(40, 40);                           % binary block model, black = 1
model(1:20, 1:20) = 1;
model(21:40, 21:40) = 1;
model(1:41:end) = 1;

figure('Color', 'w', 'Position', [60 60 1300 1000]);
x0 = [0.07 0.55];                                % left edge of the IT / vlPFC column
base = [0.52 0.02];                              % bottom of the monkey 1 / monkey 2 row
for k = 1:size(M, 2)
    for a = 1:numel(areas)
        r = M{a, k};

        % Range of the RSM values, to check that nothing falls outside the colour range
        off = r.rsm(~eye(size(r.rsm)));
        fprintf('%-5s %s (%d neurons): RSM values %.2f to %.2f, colour range %.1f to %.1f, %.0f%% of pairs below the range\n', ...
            areas{a}, animal{k}, r.nN, min(off), max(off), rsm_clim{k, a}(1), rsm_clim{k, a}(2), ...
            100 * mean(off < rsm_clim{k, a}(1)));

        % Empirical RSM
        axes('Position', [x0(a) base(k) + 0.17 0.23 0.30]);
        imagesc(r.rsm, rsm_clim{k, a});
        axis square;  colormap(gca, jet);
        set(gca, 'XTick', [], 'YTick', []);
        cb = colorbar;  cb.Ticks = rsm_clim{k, a};  cb.FontSize = 12;
        if k == 1, title(sprintf('%s RSM', areas{a}), 'FontSize', 16, 'FontWeight', 'normal'); end

        % Binary block model
        axes('Position', [x0(a) base(k) + 0.02 0.07 0.09]);
        imagesc(model);  colormap(gca, flipud(gray(256)));
        axis square;  set(gca, 'XTick', [], 'YTick', []);

        % Statistics (parametric p of the correlations)
        annotation('textbox', [x0(a) + 0.09 base(k) + 0.02 0.30 0.09], 'EdgeColor', 'none', 'FontSize', 14, ...
            'VerticalAlignment', 'middle', 'String', { ...
            sprintf('Kendall tau = %.3f, P %s', r.tau, fmt_p(r.p_tau)), ...
            sprintf('Spearman rho = %.3f, P %s', r.rho, fmt_p(r.p_rho))});
    end

    % Animal name (rotated) and panel letter, written in a transparent
    % axes that covers the whole figure
    axes('Position', [0 0 1 1], 'Visible', 'off');  xlim([0 1]);  ylim([0 1]);
    text(0.02, base(k) + 0.32, animal{k}, 'Rotation', 90, 'FontSize', 16, 'HorizontalAlignment', 'center');
    text(0.005, base(k) + 0.48, [char('A' + k - 1) '.'], 'FontSize', 16, 'FontWeight', 'bold');
end

%% ======================================================================
% Local functions

function s = fmt_p(p)
% p-value as text, without the leading "P" (used as "P %s").
if p < 0.001, s = '< 0.001'; else, s = sprintf('= %.3f', p); end
end