function fig = mmmigration(rows, cols, data, varargin)
% mmmigration - migration matrix renderer (mirrors render_migration_matrix).
%   Zero cells are light-grey; diagonal zeros show a dash; colorbar labeled 'GPU-h'.
p = inputParser;
addParameter(p, 'XLabel', 'Execution region', @ischar);
addParameter(p, 'YLabel', 'Source region', @ischar);
addParameter(p, 'FigSize', [8 6]);
addParameter(p, 'FontSize', 11, @isnumeric);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
data = double(data);
[nr, nc] = size(data);
vmax = max(data(:));
if isempty(vmax) || isnan(vmax) || vmax <= 0, vmax = 1; end
if abs(vmax) < 1e-12, vmax = 1; end

fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
cmap = blues256(256);
for i = 1:nr
    for j = 1:nc
        v = data(i, j);
        if isnan(v), continue; end
        if v <= 0
            fc = c.LIGHTGREY;
        else
            vn = min(max(v / vmax, 0), 1);
            fc = cmap(round(vn * 255) + 1, :);
        end
        rectangle(ax, 'Position', [j-0.5, i-0.5, 1, 1], 'FaceColor', fc, ...
                  'EdgeColor', [1 1 1], 'LineWidth', 1.5);
        if v > 0
            if v >= 1, tv = sprintf('%.0f', v); else, tv = sprintf('%.1f', v); end
            vn = min(max(v / vmax, 0), 1);
            if vn > 0.55, tcol = [1 1 1]; else, tcol = [0.4 0.4 0.4]; end
            text(ax, j, i, tv, 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'Color', tcol, ...
                 'FontSize', o.FontSize, 'FontName', c.FONT);
        elseif v == 0 && i == j
            text(ax, j, i, '-', 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', 'Color', [0.6 0.6 0.6], ...
                 'FontSize', o.FontSize, 'FontName', c.FONT);
        end
    end
end
set(ax, 'XLim', [-0.5, nc-0.5], 'YLim', [-0.5, nr-0.5]);
set(ax, 'XTick', 0:nc-1, 'YTick', 0:nr-1, 'YDir', 'reverse');
set(ax, 'XTickLabel', cols, 'YTickLabel', rows, 'FontSize', o.FontSize, 'FontName', c.FONT);
set(ax, 'XGrid', 'off', 'YGrid', 'off', 'Box', 'on', 'TickLength', [0 0]);
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT); end
if vmax > 0
    colormap(ax, blues256(256));
    cb = colorbar(ax);
    cb.FontSize = 10; cb.FontName = c.FONT;
    ylabel(cb, 'GPU-h', 'FontSize', 11, 'FontName', c.FONT);
    caxis(ax, [0 vmax]);
end
end
