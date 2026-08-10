function fig = mmlines(x, series, varargin)
% mmlines - multi-series line chart with triple encoding (color + linestyle + marker).
%   x: numeric vector
%   series: n x 2 cell array; series{k,1}=label, series{k,2}=y vector
p = inputParser;
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'LineWidth', 2.0, @isnumeric);
addParameter(p, 'FigSize', [10 6]);
addParameter(p, 'Markers', false, @islogical);
addParameter(p, 'Legend', true, @islogical);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
n = size(series, 1);
labels = cell(1, n);
for i = 1:n, labels{i} = series{i, 1}; end
x = double(x(:));
fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
step = max(1, round(numel(x) / 12));
for i = 1:n
    y = double(series{i, 2}(:));
    col  = c.COLORS{mod(i-1, numel(c.COLORS)) + 1};
    lstyle = c.LINESTYLES{mod(i-1, numel(c.LINESTYLES)) + 1};
    mkr    = c.MARKERS{mod(i-1, numel(c.MARKERS)) + 1};
    h = plot(ax, x, y, 'Color', col, 'LineWidth', o.LineWidth, 'LineStyle', lstyle, ...
             'Marker', mkr, 'MarkerSize', 5, ...
             'MarkerIndices', 1:step:numel(x), 'MarkerFaceColor', col, 'MarkerEdgeColor', col);
    h.DisplayName = labels{i};
end
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on'); set(ax, 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
ax.FontSize = 11; ax.FontName = c.FONT_EN;
if o.Legend
    lg = legend(ax, labels, 'Interpreter', 'none', 'FontSize', 11, 'FontName', c.FONT_CN, ...
                'Location', 'eastoutside', 'Box', 'off', 'Color', 'none');
end
end
