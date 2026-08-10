function fig = mmcorrecdf(data, cols, varargin)
% mmcorrecdf - composite: lower-tri correlation RdBu heatmap, diagonal names,
%              upper-tri ECDF of standardized values (mirrors render_correlation_ecdf).
%   data: nr x n numeric matrix
%   cols: cellstr of n variable names (long English names)
p = inputParser;
addParameter(p, 'XLabel', '变量 / 样本分位数', @ischar);
addParameter(p, 'YLabel', '相关系数 / 标准化数值', @ischar);
addParameter(p, 'FigSize', [14 10]);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
data = double(data);
[~, n] = size(data);
std_data = (data - nanmean(data)) ./ nanstd(data);
corr = corrcoef(data);
shortmap = containers.Map({'ElectricityPrice_CNY_per_MWh', 'CarbonIntensity_tCO2_per_MWh', ...
    'AvailableRenewable_MW', 'Total_Load_MW', 'NetGridImport_MW', 'SOC_MWh'}, ...
    {'电价', '碳强度', '可再生出力', '总负荷', '净购电', 'SOC'});
short = cell(1, n);
for i = 1:n
    if isKey(shortmap, cols{i}), short{i} = shortmap(cols{i}); else, short{i} = cols{i}; end
end
cmap = rdbu256(256);

fp = [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)];
fig = figure('Visible', 'off', 'Position', fp);
axs = gobjects(n, n);
ml = 0.06; mr = 0.12; mt = 0.08; mb = 0.10;
gx = 0.008; gy = 0.008;
cw = (1 - ml - mr - (n-1)*gx) / n;
ch = (1 - mt - mb - (n-1)*gy) / n;
for i = 1:n
    for j = 1:n
        px = ml + (j-1) * (cw + gx);
        py = 1 - mt - i * ch - (i-1) * gy;
        axs(i,j) = axes('Parent', fig, 'Position', [px py cw ch]);
    end
end
for i = 1:n
    for j = 1:n
        ax = axs(i, j);
        if i > j
            val = corr(i, j);
            vn = (val + 1) / 2; vn = min(max(vn, 0), 1);
            color = cmap(round(vn * 255) + 1, :);
            rectangle(ax, 'Position', [0 0 1 1], 'FaceColor', color, 'EdgeColor', [1 1 1], 'LineWidth', 1);
            if abs(val) > 0.5, tcol = [1 1 1]; else, tcol = [0.2 0.2 0.2]; end
            text(ax, 0.5, 0.5, sprintf('%.2f', val), 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 11, 'FontName', c.FONT, 'Color', tcol);
            ax.XLim = [0 1]; ax.YLim = [0 1]; axis(ax, 'off');
        elseif i == j
            rectangle(ax, 'Position', [0 0 1 1], 'FaceColor', [0.961 0.961 0.961], ...
                      'EdgeColor', [1 1 1], 'LineWidth', 1);
            text(ax, 0.5, 0.5, short{i}, 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'FontSize', 9, 'FontName', c.FONT, ...
                 'FontWeight', 'bold', 'Color', c.DARKTXT);
            ax.XLim = [0 1]; ax.YLim = [0 1]; axis(ax, 'off');
        else
            col_data = std_data(:, j);
            col_data = col_data(~isnan(col_data));
            if isempty(col_data), axis(ax,'off'); continue; end
            sd = sort(col_data);
            ecdfy = (1:numel(sd)) / numel(sd);
            pcol = c.COLORS{mod(j-1, numel(c.COLORS)) + 1};
            plot(ax, sd, ecdfy, 'Color', pcol, 'LineWidth', 1.2);
            ax.XLim = [-3 3]; ax.YLim = [0 1];
            ax.FontSize = 7;
            if i < n, ax.XTickLabel = []; end
            if j > 1, ax.YTickLabel = []; end
            grid(ax, 'off');
        end
    end
end
% shared colorbar via a dummy invisible axes spanning the right margin
cax = axes('Parent', fig, 'Position', [0.92, 0.15, 0.01, 0.7], 'Visible', 'off');
colormap(cax, cmap);
caxis(cax, [-1 1]);
cb = colorbar(cax);
cb.FontSize = 10; cb.FontName = c.FONT;
ylabel(cb, 'Pearson r', 'FontSize', 10, 'FontName', c.FONT);
% global axis labels
annotation(fig, 'textbox', [0.45 0.001 0.2 0.05], 'String', o.XLabel, ...
           'FontSize', 13, 'FontName', c.FONT, 'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'middle', 'EdgeColor', 'none');
annotation(fig, 'textbox', [0.001 0.45 0.04 0.15], 'String', o.YLabel, ...
           'FontSize', 13, 'FontName', c.FONT, 'HorizontalAlignment', 'center', ...
           'VerticalAlignment', 'middle', 'EdgeColor', 'none', 'Rotation', 90);
end
