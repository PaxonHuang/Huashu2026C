% gen_q1.m - MATLAB redraw of Q1 figures 5-10
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Times New Roman');
c = mmconfig();
DATA = c.DATA_DIR;

%% Fig 5: GPU-h structure heatmap
fprintf('q1: fig_q1_gpu_h_structure\n');
T = readtable(fullfile(DATA, 'q1_statistics.csv'));
src = cellstr(T.SourceRegion); tsk = cellstr(T.TaskType);
rows = unique(src); cols = unique(tsk);
[~, ri] = ismember(src, rows); [~, ci] = ismember(tsk, cols);
data = accumarray([ri ci], T.Total_GPUh, [numel(rows) numel(cols)], @sum, NaN);
fig = mmheatmap(rows, cols, data, 'XLabel', 'Task type', 'YLabel', 'Source region', 'Fmt', '%.0f');
mmsavepdf(fig, 'fig_q1_gpu_h_structure');

%% Fig 6: forecast total with prediction band + actual overlay
fprintf('q1: fig_q1_forecast_total\n');
F = readtable(fullfile(DATA, 'q1_forecast.csv'));
F = F(strcmp(cellstr(F.Split), 'Test_2376_2399'), :);
hours = unique(F.Hour);
n = numel(hours);
actual = zeros(n, 1); pred = zeros(n, 1);
for k = 1:n
    idx = F.Hour == hours(k);
    actual(k) = sum(F.Actual_GPUh(idx));
    pred(k) = sum(F.Selected_Predicted_GPUh(idx));
end
resid = actual - pred;
rst = std(resid);
x = hours - hours(1);
fig = mmci(x, pred, pred - 1.96*rst, pred + 1.96*rst, 'Label', 'Predicted', ...
           'XLabel', 'Relative hour in forecast window (2376=0)', 'YLabel', 'GPU-h');
ax = findobj(fig, 'Type', 'axes'); ax = ax(1);
hold(ax, 'on');
hp = plot(ax, x, actual, 'Color', c.RED, 'LineWidth', 2.0, 'Marker', 'o', 'MarkerSize', 3, 'LineStyle', '--');
hp.DisplayName = 'Actual';
lg = legend(ax, {'Predicted', 'Actual'}, 'Interpreter', 'none', 'FontSize', 11, 'FontName', c.FONT_CN, ...
            'Location', 'eastoutside', 'Box', 'off', 'Color', 'none');
mmsavepdf(fig, 'fig_q1_forecast_total');

%% Fig 7: model error comparison scatter
fprintf('q1: fig_q1_model_error_comparison\n');
M = readtable(fullfile(DATA, 'q1_forecast_metrics.csv'));
M = M(strcmp(cellstr(M.Split), 'Test_2376_2399'), :);
R = M(strcmp(cellstr(M.Model), 'Ridge'), :);
N = M(strcmp(cellstr(M.Model), 'SeasonalNaive'), :);
keyR = strcat(cellstr(R.SourceRegion), '|', cellstr(R.TaskType));
keyN = strcat(cellstr(N.SourceRegion), '|', cellstr(N.TaskType));
[~, ia, ib] = intersect(keyR, keyN, 'stable');
m_naive = N.MAE_GPUh(ib);
m_ridge = R.MAE_GPUh(ia);
% Only label outlier points (far from y=x line) to avoid text overlap
diff_val = m_naive - m_ridge;
dist = abs(diff_val) / std(diff_val);
outlier_mask = dist > 1.0;
labels_masked = cell(numel(ia), 1);
for k = 1:numel(ia)
    if outlier_mask(k)
        r = cellstr(R.SourceRegion); r = r{ia(k)};
        t = cellstr(R.TaskType); t = t{ia(k)};
        if contains(r, 'Region')
            labels_masked{k} = sprintf('%s/%s', extractAfter(r, 'Region'), t(1:2));
        else
            labels_masked{k} = r(1:min(3, numel(r)));
        end
    else
        labels_masked{k} = '';
    end
end
fig = mmscatter(m_naive, m_ridge, 'Labels', labels_masked, 'RefLine', true, ...
                'XLabel', 'Seasonal naive MAE / GPU-h', 'YLabel', 'Ridge regression MAE / GPU-h', 'FigSize', [8 8]);
mmsavepdf(fig, 'fig_q1_model_error_comparison');

%% Fig 8: schedule gantt
fprintf('q1: fig_q1_schedule_gantt\n');
S = readtable(fullfile(DATA, 'q1_schedule_2376_2399.csv'));
regions = unique(cellstr(S.ExecutionRegion));
types = {'RealTimeInference', 'BatchInference', 'AITraining'};
nr = numel(regions); nt = numel(types);
barscells = cell(nr, nt);
exr = cellstr(S.ExecutionRegion); tsk = cellstr(S.TaskType);
for i = 1:nr
    for j = 1:nt
        idx = strcmp(exr, regions{i}) & strcmp(tsk, types{j});
        if any(idx)
            barscells{i, j} = [S.StartHour(idx), S.EndHour(idx)];
        else
            barscells{i, j} = [];
        end
    end
end
fig = mmgantt(regions, types, barscells, 'StartHour', 2376, 'EndHour', 2406, 'FigSize', [14 10]);
mmsavepdf(fig, 'fig_q1_schedule_gantt');

%% Fig 9: GPU utilization lines
fprintf('q1: fig_q1_gpu_utilization\n');
U = readtable(fullfile(DATA, 'q1_utilization.csv'));
regions = unique(cellstr(U.Region));
su1 = sortrows(U(strcmp(cellstr(U.Region), regions{1}), :), 'Hour');
x = su1.Hour - 2376;
series = cell(numel(regions), 2);
for k = 1:numel(regions)
    idx = strcmp(cellstr(U.Region), regions{k});
    su = sortrows(U(idx, :), 'Hour');
    series{k, 1} = regions{k};
    series{k, 2} = su.GPU_Utilization_pct;
end
fig = mmlines(x, series, 'XLabel', 'Relative hour in tail window (2376=0)', 'YLabel', 'GPU utilization / %');
mmsavepdf(fig, 'fig_q1_gpu_utilization');

%% Fig 10: migration matrix
fprintf('q1: fig_q1_migration_matrix\n');
S = readtable(fullfile(DATA, 'q1_schedule_2376_2399.csv'));
regs = {'RegionA', 'RegionB', 'RegionC', 'RegionD', 'RegionE', 'RegionF'};
nr = numel(regs);
mat = zeros(nr);
srs = cellstr(S.SourceRegion); exr = cellstr(S.ExecutionRegion);
for i = 1:nr
    for j = 1:nr
        idx = strcmp(srs, regs{i}) & strcmp(exr, regs{j});
        mat(i, j) = sum(S.GPU_h(idx));
    end
end
fig = mmmigration(regs, regs, mat, 'FigSize', [8 6]);
mmsavepdf(fig, 'fig_q1_migration_matrix');

fprintf('Q1 done\n');
