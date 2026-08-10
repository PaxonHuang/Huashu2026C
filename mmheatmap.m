function fig = mmheatmap(rows, cols, data, varargin)
% mmheatmap - annotated heatmap (mirrors render_heatmap).
%   rows: cellstr of row labels (top-to-bottom order)
%   cols: cellstr of column labels
%   data: nr x nc numeric matrix, NaN cells are left blank
p = inputParser;
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'Fmt', '%.0f', @ischar);
addParameter(p, 'FigSize', [10 7]);
addParameter(p, 'VMin', [], @isnumeric);
addParameter(p, 'VMax', [], @isnumeric);
addParameter(p, 'CBarLabel', '', @ischar);
addParameter(p, 'FontSize', 11, @isnumeric);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
data = double(data);
[nr, nc] = size(data);
vmin = o.VMin; if isempty(vmin), vmin = nanmin(data(:)); end
vmax = o.VMax; if isempty(vmax), vmax = nanmax(data(:)); end
if isnan(vmin), vmin = 0; end
if isnan(vmax), vmax = 1; end
if abs(vmax - vmin) < 1e-12, vmax = vmin + 1; end

fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
imagesc(ax, 1:nc, 1:nr, data);
colormap(ax, blues256(256));
caxis(ax, [vmin vmax]);
hold(ax, 'on');
for i = 1:nr
    for j = 1:nc
        v = data(i, j);
        if isnan(v), continue; end
        vn = (v - vmin) / (vmax - vmin);
        vn = min(max(vn, 0), 1);
        if vn > 0.55, tcol = [1 1 1]; else, tcol = [0.2 0.2 0.2]; end
        text(ax, j, i, sprintf(o.Fmt, v), 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', 'Color', tcol, ...
             'FontSize', o.FontSize, 'FontName', c.FONT_EN);
    end
end
set(ax, 'XTick', 1:nc, 'YTick', 1:nr, 'YDir', 'reverse');
set(ax, 'XTickLabel', cols, 'YTickLabel', rows, 'FontSize', o.FontSize, 'FontName', c.FONT_EN);
set(ax, 'XGrid', 'off', 'YGrid', 'off', 'Box', 'on');
set(ax, 'TickLength', [0 0], 'Layer', 'top', 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
cb = colorbar(ax);
cb.FontSize = 10; cb.FontName = c.FONT_EN;
cb.TickLabelInterpreter = 'none';
if ~isempty(o.CBarLabel), ylabel(cb, o.CBarLabel, 'FontSize', 11, 'FontName', c.FONT_CN); end
end
