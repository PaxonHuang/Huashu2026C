% gen_q3.m - MATLAB redraw of Q3 figures 16-20
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Times New Roman');
c = mmconfig();
DATA = c.DATA_DIR;

%% Fig 16: KPI improvement single bars
fprintf('q3: fig_q3_kpi_improvement\n');
T = readtable(fullfile(DATA, 'q3_kpi.csv'));
% CSV Metric column is Chinese; remap to English for display
kpi_zh_to_en = containers.Map( ...
    {'运行成本', '碳排放', '区域峰值净购电', '净购电波动'}, ...
    {'Op. cost', 'Carbon', 'Peak net import', 'Net import variability'});
cats_zh = cellstr(T.Metric);
cats = cellfun(@(m) kpi_zh_to_en(m), cats_zh, 'Uni', 0);
vals = T.ImprovementPercent;
fig = mmbars(cats, vals, 'YLabel', 'Improvement (%)');
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
for k = 1:numel(vals)
    text(ax, k, vals(k) + 1, sprintf('%.1f%%', vals(k)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'FontName', c.FONT, 'Color', c.DARKTXT);
end
mmsavepdf(fig, 'fig_q3_kpi_improvement');

%% Fig 17: net import duration curve
fprintf('q3: fig_q3_net_import_duration\n');
T = readtable(fullfile(DATA, 'q3_net_import_duration.csv'));
series = {'Baseline', T.BaselineNetGridImport_MW; 'Optimized', T.OptimizedNetGridImport_MW};
fig = mmlines(T.RankHour, series, 'XLabel', 'Ranked hour', 'YLabel', 'Net grid import (MW)');
mmsavepdf(fig, 'fig_q3_net_import_duration');

%% Fig 18: renewable utilization by region (Chinese headers in CSV)
fprintf('q3: fig_q3_renewable_utilization\n');
T = readtable(fullfile(DATA, 'q3_renewable_by_region.csv'), 'Encoding', 'UTF-8', 'VariableNamingRule', 'preserve');
reg = cellstr(T.Region);
vnames = T.Properties.VariableNames;
% CSV columns are Chinese; remap to English for display
zh_to_en = containers.Map({'附件基准', '储能协同'}, {'Baseline', 'Storage co-op'});
series = {zh_to_en(vnames{2}), T{:, 2}; zh_to_en(vnames{3}), T{:, 3}};
fig = mmbars(reg, series, 'XLabel', 'Region', 'YLabel', 'Renewable utilization (%)', 'ValueLabels', true);
mmsavepdf(fig, 'fig_q3_renewable_utilization');

%% Fig 19: SOC trajectories (charge-up window: first 6 hours)
% Source data: each region charges for only 3-4 hours then sits at the cap
% (DischargePower is always 0). Plotting the full 2407-hour timeline makes
% every line look flat. Switch to the first 6 hours so the actual charge
% ramp dynamics are visible, and overlay each region's capacity ceiling.
fprintf('q3: fig_q3_soc_trajectories\n');
T = readtable(fullfile(DATA, 'q3_storage_dispatch.csv'));
regs = unique(cellstr(T.Region));
% Capacity per region (MWh) from final unique SOC value (cap)
caps = zeros(numel(regs), 1);
for k = 1:numel(regs)
    su = sortrows(T(strcmp(cellstr(T.Region), regs{k}), :), 'Hour');
    caps(k) = max(su.SOC_MWh);
end
% Use first 6 hours only — captures the charge ramp before plateau
win = 6;
x = (0:win-1)';
series = cell(numel(regs), 2);
for k = 1:numel(regs)
    su = sortrows(T(strcmp(cellstr(T.Region), regs{k}), :), 'Hour');
    series{k, 1} = regs{k};
    series{k, 2} = su.SOC_MWh(1:win);
end
fig = mmlines(x, series, 'XLabel', 'Hour (charge-up window)', ...
              'YLabel', 'SOC (MWh)', 'Markers', true, 'FigSize', [11 6.5]);
% Overlay cap ceilings as dotted grey lines, each at its region's own cap
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
hold(ax, 'on');
for k = 1:numel(regs)
    yline(ax, caps(k), ':', '', ...
          'Color', c.GREYTXT, 'LineWidth', 0.8, ...
          'HandleVisibility', 'off');
    text(ax, win - 0.15, caps(k), sprintf('%s cap = %.0f MWh', regs{k}, caps(k)), ...
         'FontSize', 8, 'FontName', c.FONT_EN, 'Color', c.GREYTXT, ...
         'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
         'HandleVisibility', 'off');
end
mmsavepdf(fig, 'fig_q3_soc_trajectories');

%% Fig 20: typical dispatch window
fprintf('q3: fig_q3_typical_dispatch\n');
T = readtable(fullfile(DATA, 'q3_typical_window.csv'));
series = {'Baseline net import', T.BaselineNetGridImport_MW; 'Optimized net import', T.OptimizedNetGridImport_MW; ...
           'Charge power', T.ChargePower_MW; 'Discharge power', T.DischargePower_MW};
fig = mmlines(T.Hour, series, 'XLabel', 'Hour', 'YLabel', 'Power (MW)');
mmsavepdf(fig, 'fig_q3_typical_dispatch');

fprintf('Q3 done\n');
