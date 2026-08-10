function fig = mmbars(categories, series, varargin)
% mmbars - grouped or single bar chart (mirrors render_grouped_bars / render_single_bars).
%   categories: cellstr
%   series: numeric vector (single bars) OR n x 2 cell {label, values} for grouped bars
p = inputParser;
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'FigSize', [10 6]);
addParameter(p, 'ValueLabels', false, @islogical);
addParameter(p, 'RotateLabels', 0, @isnumeric);
addParameter(p, 'Legend', true, @islogical);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
ncat = numel(categories);
fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
if isnumeric(series)
    vals = double(series(:))';
    b = bar(ax, 1:ncat, vals, 'FaceColor', c.BLUE, 'EdgeColor', [1 1 1], 'LineWidth', 0.5, 'BarWidth', 0.7);
    if o.ValueLabels
        for k = 1:ncat
            text(ax, b.XEndPoints(k), b.YEndPoints(k), sprintf('%.2f', vals(k)), ...
                 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                 'FontSize', 8, 'FontName', c.FONT_EN, 'Color', c.DARKTXT);
        end
    end
    if o.Legend, legend(ax, 'off'); end
else
    ns = size(series, 1);
    labels = cell(1, ns);
    for i = 1:ns, labels{i} = series{i, 1}; end
    for i = 1:ns
        vals = double(series{i, 2}(:))';
        b = bar(ax, 1:ncat, vals, 'BarWidth', 0.8/ns*0.9, ...
                'FaceColor', c.COLORS{mod(i-1, numel(c.COLORS)) + 1}, ...
                'EdgeColor', [1 1 1], 'LineWidth', 0.5);
        b.DisplayName = labels{i};
        if o.ValueLabels
            for k = 1:ncat
                text(ax, b.XEndPoints(k), b.YEndPoints(k), sprintf('%.2f', vals(k)), ...
                     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                     'FontSize', 8, 'FontName', c.FONT_EN, 'Color', c.DARKTXT);
            end
        end
    end
    if o.Legend
        lg = legend(ax, labels, 'Interpreter', 'none', 'FontSize', 11, 'FontName', c.FONT_CN, ...
                    'Location', 'eastoutside', 'Box', 'off', 'Color', 'none');
    end
end
set(ax, 'XTick', 1:ncat, 'XTickLabel', categories, 'FontSize', 11, 'FontName', c.FONT_EN);
if o.RotateLabels > 0
    set(ax, 'XTickLabelRotation', o.RotateLabels);
end
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on'); set(ax, 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
end
