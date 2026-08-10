% gen_q2.m - MATLAB redraw of Q2 figures 11-15
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Times New Roman');
c = mmconfig();
DATA = c.DATA_DIR;

%% Fig 11: KPI improvement - 1x3 split subplots (each metric on its own scale)
% Old version grouped all three on one axis, making Carbon (~8.85) and Peak
% net import (~31.6) invisible next to Op. cost (~8215). Now each panel has
% independent ylim so all bars are readable.
fprintf('q2: fig_q2_kpi_improvement\n');
T = readtable(fullfile(DATA, 'q2_kpi.csv'));
key_metrics = {'运行成本/CNY', '碳排放/tCO2', '峰值净购电/MW'};
idx = ismember(cellstr(T.Metric), key_metrics);
Tp = T(idx, :);
key_to_en = containers.Map( ...
    {'运行成本/CNY', '碳排放/tCO2', '峰值净购电/MW'}, ...
    {'Op. cost (10^3 CNY)', 'Carbon (tCO2)', 'Peak net import (MW)'});
panel_labels = cellfun(@(m) key_to_en(m), cellstr(Tp.Metric), 'Uni', 0);

n_panels = height(Tp);
fig = figure('Visible', 'off', 'Position', [50 50 1400 480], 'Renderer', 'painters');
for k = 1:n_panels
    ax = subplot(1, n_panels, k);
    vals = [Tp.Baseline(k); Tp.Optimized(k)];
    b = bar(ax, [1 2], vals, 'BarWidth', 0.55, ...
            'FaceColor', 'flat', 'EdgeColor', [1 1 1], 'LineWidth', 0.5);
    b.CData = [c.BLUE; c.GREEN];    % per-bar colors (Baseline, Optimized)
    set(ax, 'XTick', [1 2], 'XTickLabel', {'Baseline', 'Optimized'}, ...
            'FontSize', 11, 'FontName', c.FONT_EN, 'LineWidth', 1.1, 'TickDir', 'in');
    % Tight ylim around the pair so bars dominate the panel
    ymax = max(vals) * 1.18;
    set(ax, 'YLim', [0 ymax]);
    % Value labels above each bar
    text(ax, 1, vals(1)*1.04, sprintf('%.2f', vals(1)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 9, 'FontName', c.FONT_EN, 'Color', c.DARKTXT);
    text(ax, 2, vals(2)*1.04, sprintf('%.2f', vals(2)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 9, 'FontName', c.FONT_EN, 'Color', c.DARKTXT);
    % Improvement percentage as a green label between the bars (top)
    pct = Tp.ImprovementPercent(k);
    text(ax, 1.5, ymax*0.95, sprintf('-%.1f%%', pct), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
         'FontSize', 11, 'FontName', c.FONT_EN, 'FontWeight', 'bold', 'Color', c.GREEN);
    grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
    box(ax, 'on');
    ylabel(ax, panel_labels{k}, 'FontSize', 12, 'FontName', c.FONT_CN);
    title(ax, panel_labels{k}, 'FontSize', 12, 'FontName', c.FONT_CN, 'FontWeight', 'bold');
end
mmsavepdf(fig, 'fig_q2_kpi_improvement');

%% Fig 12: migration matrix
fprintf('q2: fig_q2_migration_matrix\n');
T = readtable(fullfile(DATA, 'q2_migration_matrix.csv'));
regs = {'RegionA','RegionB','RegionC','RegionD','RegionE','RegionF'};
mat = zeros(numel(regs));
for i = 1:numel(regs)
    row = T(strcmp(cellstr(T.SourceRegion), regs{i}), :);
    for j = 1:numel(regs)
        mat(i, j) = row.(regs{j});
    end
end
fig = mmmigration(regs, regs, mat);
mmsavepdf(fig, 'fig_q2_migration_matrix');

%% Fig 13: AI load heatmap (Region x Hour)
fprintf('q2: fig_q2_ai_load_heatmap\n');
T = readtable(fullfile(DATA, 'q2_hourly_load.csv'));
hrs = unique(T.Hour); regs = unique(cellstr(T.Region));
[~, ri] = ismember(cellstr(T.Region), regs); [~, ci] = ismember(T.Hour, hrs);
data = accumarray([ri ci], T.Optimized_AI_IT_MW, [numel(regs) numel(hrs)], @sum, NaN);
% Convert hrs to cellstr for tick labels (avoid type mismatch)
hrs_labels = arrayfun(@(h) sprintf('%d', h), hrs, 'Uni', 0);
fig = mmheatmap(regs, hrs_labels, data, 'XLabel', 'Hour of day', 'YLabel', 'Region', ...
                'Fmt', '%.1f', 'FigSize', [12 7]);
mmsavepdf(fig, 'fig_q2_ai_load_heatmap');

%% Fig 14: diurnal profile lines
fprintf('q2: fig_q2_diurnal_profile\n');
T = readtable(fullfile(DATA, 'q2_diurnal_profile.csv'));
series = {'Baseline', T.Baseline_AI_IT_MW; 'Optimized', T.Optimized_AI_IT_MW};
fig = mmlines(T.HourOfDay, series, 'XLabel', 'Hour of day', 'YLabel', 'AI IT load (MW)', 'Markers', true);
mmsavepdf(fig, 'fig_q2_diurnal_profile');

%% Fig 15: renewable by region - diverging bar (% change vs baseline)
% Old version stacked Baseline (56.97 MWh) and Optimized (56.97 MWh) on one
% axis with auto ylim 50.81-59.02, hiding the tiny 0.05 MWh differences. New
% version converts to "% change vs baseline" so the contrast is visible.
fprintf('q2: fig_q2_renewable_by_region\n');
T = readtable(fullfile(DATA, 'q2_renewable_by_region.csv'));
delta = ((T.Optimized - T.Baseline) ./ T.Baseline) * 100;  % percent change
reg = cellstr(T.Region);

fig = figure('Visible', 'off', 'Position', [50 50 900 500], 'Renderer', 'painters');
ax = axes('Parent', fig);
hold(ax, 'on');
% Color by sign: positive -> green, negative -> red
colors = repmat(c.GREEN, numel(delta), 1);
colors(delta < 0, :) = repmat(c.RED, sum(delta < 0), 1);
b = bar(ax, 1:numel(delta), delta, 'BarWidth', 0.6, ...
        'FaceColor', 'flat', 'EdgeColor', [1 1 1], 'LineWidth', 0.5);
b.CData = colors;
set(ax, 'XTick', 1:numel(delta), 'XTickLabel', reg, ...
        'FontSize', 11, 'FontName', c.FONT_EN, 'LineWidth', 1.1, 'TickDir', 'in');
% Value labels above/below each bar
for k = 1:numel(delta)
    va = 'bottom'; dy = 0.04;
    if delta(k) < 0, va = 'top'; dy = -0.04; end
    text(ax, k, delta(k) + dy, sprintf('%+.2f%%', delta(k)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', va, ...
         'FontSize', 9, 'FontName', c.FONT_EN, 'Color', c.DARKTXT);
end
% Ylim symmetric around 0 with margin
yabs = max(abs(delta)) * 1.4;
set(ax, 'YLim', [-yabs yabs]);
yline(ax, 0, '--', 'Color', c.GREYTXT, 'LineWidth', 1.0);
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on');
ylabel(ax, 'Change vs baseline (%)', 'FontSize', 13, 'FontName', c.FONT_CN);
xlabel(ax, 'Region', 'FontSize', 13, 'FontName', c.FONT_CN);
title(ax, 'Renewable absorption: % change (Optimized - Baseline)', ...
      'FontSize', 13, 'FontName', c.FONT_CN);
mmsavepdf(fig, 'fig_q2_renewable_by_region');

fprintf('Q2 done\n');