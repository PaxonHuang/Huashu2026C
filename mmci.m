function fig = mmci(x, y, lo, hi, varargin)
% mmci - line with confidence band (mirrors render_lines_with_ci).
p = inputParser;
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'Label', '', @ischar);
addParameter(p, 'Color', [0.231 0.286 0.573]);
addParameter(p, 'FigSize', [10 6]);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
x = double(x(:)); y = double(y(:)); lo = double(lo(:)); hi = double(hi(:));
valid = isfinite(y) & isfinite(lo) & isfinite(hi);
x = x(valid); y = y(valid); lo = lo(valid); hi = hi(valid);
fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
xf = [x(:); flipud(x(:))]; yf = [lo(:); flipud(hi(:))];
fill(ax, xf, yf, o.Color, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');
h = plot(ax, x, y, 'Color', o.Color, 'LineWidth', 2.0);
if ~isempty(o.Label), h.DisplayName = o.Label; end
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on'); set(ax, 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
ax.FontSize = 11; ax.FontName = c.FONT_EN;
if ~isempty(o.Label)
    lg = legend(ax, 'Interpreter', 'none', 'FontSize', 11, 'FontName', c.FONT_CN, ...
                'Location', 'bestoutside', 'Box', 'off', 'Color', 'none');
end
end
