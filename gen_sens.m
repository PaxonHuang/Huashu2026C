% gen_sens.m - MATLAB redraw of Sensitivity figures 27-29
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Microsoft YaHei');
c = mmconfig();
DATA = c.DATA_DIR;

%% Fig 27: normalized metrics heatmap (melted)
fprintf('sens: fig_sensitivity_normalized_metrics\n');
T = readtable(fullfile(DATA, 'sensitivity_scenario_metrics.csv'), 'Encoding', 'UTF-8', 'VariableNamingRule', 'preserve');
% Find Chinese loss columns by partial match
vnames = T.Properties.VariableNames;
loss_cols = vnames(contains(vnames, '归一化损失'));
if isempty(loss_cols)
    loss_cols = {'Cost_CNY', 'Carbon_tCO2', 'WeightedLatency_ms', 'MeanWait_h', 'PeakNetGridImport_MW'};
    loss_cols = loss_cols(ismember(loss_cols, vnames));
end
% label col
if any(strcmp(vnames, 'ScenarioLabel')), label_col = 'ScenarioLabel'; else, label_col = 'Scenario'; end
nr = height(T); nl = numel(loss_cols);
data = zeros(nr, nl);
labs = cellstr(T.(label_col));
for k = 1:nl
    col = T.(loss_cols{k});
    if iscell(col), col = cellfun(@str2double, col); end
    data(:, k) = col;
end
fig = mmheatmap(loss_cols, labs, data', 'XLabel', '情景', 'YLabel', '指标', ...
                'Fmt', '%.3f', 'FigSize', [12 7]);
mmsavepdf(fig, 'fig_sensitivity_normalized_metrics');

%% Fig 28: renewable elasticity grouped bars
fprintf('sens: fig_sensitivity_renewable_elasticity\n');
T = readtable(fullfile(DATA, 'sensitivity_elasticity.csv'));
idx = contains(cellstr(T.InputVariable), 'renewable') | contains(cellstr(T.InputVariable), 'Renewable') | contains(cellstr(T.InputVariable), '新能源');
if ~any(idx), idx = true(height(T), 1); end
Tr = T(idx, :);
cats = cellstr(Tr.Metric);
series = {'弹性系数', Tr.CentralElasticity};
fig = mmbars(cats, series, 'XLabel', '指标', 'YLabel', '弹性系数', 'RotateLabels', 30, 'ValueLabels', true);
mmsavepdf(fig, 'fig_sensitivity_renewable_elasticity');

%% Fig 29: robustness grouped bars
fprintf('sens: fig_sensitivity_robustness\n');
T = readtable(fullfile(DATA, 'sensitivity_robustness.csv'));
cats = cellstr(T.ScenarioFamily);
series = {'平均稳健性得分', T.MeanRobustnessScore; '最小稳健性得分', T.MinRobustnessScore};
fig = mmbars(cats, series, 'XLabel', '情景族', 'YLabel', '稳健性得分', 'RotateLabels', 15, 'ValueLabels', true);
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
yl = get(ax, 'YLim');
hline = yline(ax, 1.0, '--', 'Color', c.GREEN, 'LineWidth', 1.5, 'Alpha', 0.7);
hline.DisplayName = '理想值=1.0';
lg = legend(ax, 'Interpreter', 'none', 'FontSize', 11, 'FontName', c.FONT, ...
            'Box', 'on', 'EdgeColor', [0.8 0.8 0.8], 'Location', 'best');
mmsavepdf(fig, 'fig_sensitivity_robustness');

fprintf('Sensitivity done\n');
