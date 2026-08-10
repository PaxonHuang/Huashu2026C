% gen_eda.m - MATLAB redraw of EDA figures 1-4
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Microsoft YaHei');
c = mmconfig();
DATA = c.DATA_DIR;

%% Fig 1: GPU-h structure heatmap
fprintf('eda: fig_eda_gpu_h_structure\n');
T = readtable(fullfile(DATA, 'eda_summary.csv'));
src = cellstr(T.SourceRegion); tsk = cellstr(T.TaskType);
rows = unique(src); cols = unique(tsk);
[~, ri] = ismember(src, rows); [~, ci] = ismember(tsk, cols);
data = accumarray([ri ci], T.GPU_h, [numel(rows) numel(cols)], @sum, NaN);
fig = mmheatmap(rows, cols, data, 'XLabel', '任务类型', 'YLabel', '来源区域', 'Fmt', '%.0f');
mmsavepdf(fig, 'fig_eda_gpu_h_structure');

%% Fig 2: arrival profile cumulative lines
fprintf('eda: fig_eda_arrival_profile\n');
T = readtable(fullfile(DATA, 'eda_hourly.csv'));
hours = unique(T.Hour);
cols = unique(cellstr(T.TaskType));
[~, ri] = ismember(T.Hour, hours); [~, ci] = ismember(cellstr(T.TaskType), cols);
data = accumarray([ri ci], T.GPU_h, [numel(hours) numel(cols)], @sum, 0);
cum = cumsum(data, 1);
series = cell(numel(cols), 2);
for k = 1:numel(cols)
    series{k, 1} = cols{k};
    series{k, 2} = cum(:, k);
end
fig = mmlines(hours, series, 'XLabel', '到达小时（0-23 时）', 'YLabel', '累计到达 GPU-h');
mmsavepdf(fig, 'fig_eda_arrival_profile');

%% Fig 3: energy correlation + ECDF composite
fprintf('eda: fig_eda_energy_correlation_distribution\n');
E = readtable(fullfile(DATA, 'region_time_data.xlsx'));
energy_cols = {'ElectricityPrice_CNY_per_MWh', 'CarbonIntensity_tCO2_per_MWh', ...
    'AvailableRenewable_MW', 'Total_Load_MW', 'NetGridImport_MW', 'SOC_MWh'};
M = zeros(height(E), numel(energy_cols));
for k = 1:numel(energy_cols)
    M(:, k) = E.(energy_cols{k});
end
fig = mmcorrecdf(M, energy_cols);
mmsavepdf(fig, 'fig_eda_energy_correlation_distribution');

%% Fig 4: energy diurnal profile
fprintf('eda: fig_eda_energy_diurnal_profile\n');
E.Hour = mod(E.Hour, 24);
hours = (0:23)';
meanarr = zeros(24, 3);
for h = 1:24
    idx = E.Hour == hours(h);
    meanarr(h, 1) = mean(E.AvailableRenewable_MW(idx));
    meanarr(h, 2) = mean(E.Total_Load_MW(idx));
    meanarr(h, 3) = mean(E.NetGridImport_MW(idx));
end
series = {'可再生出力', meanarr(:, 1); '总负荷', meanarr(:, 2); '净购电', meanarr(:, 3)};
fig = mmlines(hours, series, 'XLabel', '小时（0-23 时）', 'YLabel', '平均功率（MW）');
mmsavepdf(fig, 'fig_eda_energy_diurnal_profile');

fprintf('EDA done\n');
