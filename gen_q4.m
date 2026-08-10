% gen_q4.m - MATLAB redraw of Q4 figures 21-26
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Times New Roman');
c = mmconfig();
DATA = c.DATA_DIR;

% Q4 CSVs use Chinese scenario names; map to English for display
zh2en = containers.Map( ...
    {'目标权重', '电价机制', '新能源波动', ...
     '经济优先', '均衡', '低碳优先', '服务优先', ...
     '原始分时', '平价化', '峰谷差扩大20%', ...
     '新能源-20%', '新能源基准', '新能源+20%', ...
     '服务-低碳中间1', '服务-低碳中间2'}, ...
    {'Objective weight', 'Tariff mechanism', 'Renewable variability', ...
     'Economy priority', 'Balanced', 'Low-carbon priority', 'Service priority', ...
     'Original TOU', 'Flattened', 'Peak-valley spread +20%', ...
     'Renewable -20%', 'Renewable baseline', 'Renewable +20%', ...
     'Service->low-carbon interp 1', 'Service->low-carbon interp 2'});
translate = @(cellarr) cellfun(@(s) zh2en(s), cellarr, 'Uni', 0);

%% Fig 21: carbon budget (cap as dashed ceiling + achieved as bars + slack shading)
% Old version paired Carbon cap and Achieved as grouped bars; at 100% cap the
% Achieved (~0.32 tCO2) was dwarfed by Cap (~8.85 tCO2). New version shows
% Achieved as bars, Cap as a dashed ceiling line, and the slack (Cap minus
% Achieved) as light shading — makes the binding constraint visible.
fprintf('q4: fig_q4_carbon_budget\n');
T = readtable(fullfile(DATA, 'q4_carbon_budget.csv'));
cats = arrayfun(@(p) sprintf('%d%%', p), T.CarbonCapPercent, 'Uni', 0);

fig = figure('Visible', 'off', 'Position', [50 50 900 500], 'Renderer', 'painters');
ax = axes('Parent', fig);
hold(ax, 'on');
n = height(T);
b = bar(ax, 1:n, T.AchievedCarbon_tCO2, 'BarWidth', 0.55, ...
        'FaceColor', c.BLUE, 'EdgeColor', [1 1 1], 'LineWidth', 0.5);
% Cap as dashed line
plot(ax, 1:n, T.CarbonCap_tCO2, '--', 'Color', c.RED, 'LineWidth', 1.6, ...
     'Marker', 'o', 'MarkerSize', 7, 'MarkerFaceColor', c.RED);
% Slack shading
for k = 1:n
    xv = [k-0.27, k+0.27, k+0.27, k-0.27];
    yv = [T.AchievedCarbon_tCO2(k), T.AchievedCarbon_tCO2(k), ...
          T.CarbonCap_tCO2(k), T.CarbonCap_tCO2(k)];
    fill(ax, xv, yv, c.ORANGE, 'FaceAlpha', 0.18, 'EdgeColor', 'none');
end
set(ax, 'XTick', 1:n, 'XTickLabel', cats, 'FontSize', 12, 'FontName', c.FONT_EN, ...
        'LineWidth', 1.1, 'TickDir', 'in');
% Value labels above each achieved bar
for k = 1:n
    text(ax, k, T.AchievedCarbon_tCO2(k) + max(T.CarbonCap_tCO2)*0.02, ...
         sprintf('%.2f', T.AchievedCarbon_tCO2(k)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 10, 'FontName', c.FONT_EN, 'Color', c.DARKTXT);
    text(ax, k, T.CarbonCap_tCO2(k) + max(T.CarbonCap_tCO2)*0.02, ...
         sprintf('%.2f', T.CarbonCap_tCO2(k)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
         'FontSize', 10, 'FontName', c.FONT_EN, 'Color', c.RED);
end
ymax = max(T.CarbonCap_tCO2) * 1.15;
set(ax, 'YLim', [0 ymax]);
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on');
ylabel(ax, 'Carbon (tCO2)', 'FontSize', 13, 'FontName', c.FONT_CN);
xlabel(ax, 'Carbon cap (% of baseline)', 'FontSize', 13, 'FontName', c.FONT_CN);
title(ax, 'Carbon budget: achieved vs cap (shaded = slack)', ...
      'FontSize', 13, 'FontName', c.FONT_CN);
legend(ax, {'Achieved', 'Cap', 'Slack'}, 'Location', 'northwest', ...
       'FontSize', 11, 'FontName', c.FONT_CN, 'Box', 'off', 'Color', 'none');
mmsavepdf(fig, 'fig_q4_carbon_budget');

%% Fig 22: migration matrix
fprintf('q4: fig_q4_migration_matrix\n');
T = readtable(fullfile(DATA, 'q4_migration_matrix.csv'));
regs = {'RegionA','RegionB','RegionC','RegionD','RegionE','RegionF'};
mat = zeros(numel(regs));
for i = 1:numel(regs)
    row = T(strcmp(cellstr(T.SourceRegion), regs{i}), :);
    for j = 1:numel(regs)
        mat(i, j) = row.(regs{j});
    end
end
fig = mmmigration(regs, regs, mat);
mmsavepdf(fig, 'fig_q4_migration_matrix');

%% Fig 23: objective parallel grouped bars
fprintf('q4: fig_q4_objective_parallel\n');
T = readtable(fullfile(DATA, 'q4_objective_normalized.csv'));
metrics = {'Cost_CNY', 'Carbon_tCO2', 'MeanWait_h', 'PeakNetGridImport_MW'};
cats = translate(cellstr(T.Scenario));
series = cell(numel(metrics), 2);
for k = 1:numel(metrics)
    col = T.(metrics{k});
    cm = max(col);
    if cm > 0, col = col / cm; end
    nm = strrep(metrics{k}, '_', ' ');
    series{k, 1} = nm;
    series{k, 2} = col;
end
fig = mmbars(cats, series, 'YLabel', 'Normalized value', 'RotateLabels', 15);
mmsavepdf(fig, 'fig_q4_objective_parallel');

%% Fig 24: Pareto front scatter
% Upstream cost model reports negative costs. Negate to get positive values
% (so larger = higher cost = "worse" in the usual sense). 9 points span 3
% scenario groups; renewable outliers get a log y-axis so the trade-off is
% visible across orders of magnitude.
fprintf('q4: fig_q4_pareto\n');
T = readtable(fullfile(DATA, 'q4_pareto.csv'));
groups_zh = unique(cellstr(T.ScenarioGroup));
groups = translate(groups_zh);
ng = numel(groups);
pts = cell(1, ng); labels = cell(1, ng);
for k = 1:ng
    idx = strcmp(cellstr(T.ScenarioGroup), groups_zh{k});
    pts{k} = [(-T.Cost_CNY(idx))'; T.Carbon_tCO2(idx)'];   % negate cost
    labels{k} = translate(cellstr(T.Scenario(idx)));
end
% Display cost in M CNY
cost_unit = 1e6;
for k = 1:ng
    pts{k}(1, :) = pts{k}(1, :) / cost_unit;
end
fig = mmpareto(groups, pts, labels, ...
               'XLabel', 'Total cost (M CNY)', ...
               'YLabel', 'Carbon (tCO2, log scale)', ...
               'FigSize', [12 9]);
% Apply log y-axis to compress the renewable outlier (11933 tCO2)
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
set(ax, 'YScale', 'log');
% Set a sensible y-range so the cluster near 0 is still visible
yl = [0.05, max(T.Carbon_tCO2) * 1.2];
set(ax, 'YLim', yl);
mmsavepdf(fig, 'fig_q4_pareto');

%% Fig 25: price mechanism grouped bars (normalize both to [0,1] for visual comparison)
fprintf('q4: fig_q4_price_mechanism\n');
T = readtable(fullfile(DATA, 'q4_price_mechanism.csv'));
cats = translate(cellstr(T.Scenario));
cost_norm = T.Cost_CNY / max(abs(T.Cost_CNY));
carbon_norm = T.Carbon_tCO2 / max(abs(T.Carbon_tCO2));
series = {'Cost (norm.)', cost_norm; 'Carbon (norm.)', carbon_norm};
fig = mmbars(cats, series, 'YLabel', 'Normalized value', 'RotateLabels', 15, 'ValueLabels', true);
mmsavepdf(fig, 'fig_q4_price_mechanism');

%% Fig 26: renewable scenarios grouped bars
fprintf('q4: fig_q4_renewable_scenarios\n');
T = readtable(fullfile(DATA, 'q4_renewable_scenarios.csv'));
cats = translate(cellstr(T.Scenario));
series = {'Renewable utilization (%)', T.RenewableUtilization * 100; 'Cost (M CNY)', T.Cost_CNY / 1e6};
fig = mmbars(cats, series, 'YLabel', 'Value', 'RotateLabels', 15, 'ValueLabels', true);
mmsavepdf(fig, 'fig_q4_renewable_scenarios');

fprintf('Q4 done\n');
