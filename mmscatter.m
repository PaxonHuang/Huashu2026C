function fig = mmscatter(x, y, varargin)
% mmscatter - scatter with optional point labels and y=x reference line.
p = inputParser;
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'Labels', {}, @iscell);
addParameter(p, 'RefLine', false, @islogical);
addParameter(p, 'Color', [0.231 0.286 0.573]);
addParameter(p, 'FigSize', [8 8]);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
x = double(x(:)); y = double(y(:));
fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
scatter(ax, x, y, 60, o.Color, 'filled', 'MarkerEdgeColor', [1 1 1], 'LineWidth', 0.8);
if ~isempty(o.Labels)
    xr = max(x) - min(x); yr = max(y) - min(y);
    if xr == 0, xr = 1; end
    if yr == 0, yr = 1; end
    for i = 1:numel(o.Labels)
        % Vary offset direction based on quadrant relative to median
        dx = 0.012 * xr; dy = 0.012 * yr;
        if x(i) > median(x), ha = 'left'; else, ha = 'right'; dx = -dx; end
        if y(i) > median(y), va = 'bottom'; else, va = 'top'; dy = -dy; end
        text(ax, x(i) + dx, y(i) + dy, o.Labels{i}, 'FontSize', 7.5, 'FontName', c.FONT_EN, ...
             'Color', [0.25 0.25 0.25], 'HorizontalAlignment', ha, 'VerticalAlignment', va);
    end
end
if o.RefLine
    lims = [min(min(x), min(y)), max(max(x), max(y))];
    h = plot(ax, lims, lims, '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);
    h.DisplayName = 'y=x';
end
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on'); set(ax, 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
ax.FontSize = 11; ax.FontName = c.FONT_EN;
if o.RefLine
    lg = legend(ax, 'FontSize', 11, 'FontName', c.FONT_CN, ...
                'Location', 'eastoutside', 'Box', 'off', 'Color', 'none');
end
end
