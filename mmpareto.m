function fig = mmpareto(groups, pts, labels, varargin)
% mmpareto - grouped scatter with per-group colors and labels (mirrors render_pareto).
%   groups: cellstr of group names
%   pts: cell {groupname -> [x; y]} or struct {groupname: [x(:), y(:)]}
%   labels: cell {groupname -> cellstr} or struct {groupname: {lbl...}}
p = inputParser;
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'FigSize', [10 8]);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
if iscell(pts)
    names = groups;
elseif isstruct(pts)
    names = fieldnames(pts);
    groups = names;
end
ng = numel(names);
fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
allx = []; ally = [];
for i = 1:ng
    g = names{i};
    if iscell(pts)
        xy = pts{i}; x = double(xy(1, :)); y = double(xy(2, :));
    else
        x = double(pts.(g)(:, 1)); y = double(pts.(g)(:, 2));
    end
    allx = [allx x]; ally = [ally y];
    col = c.COLORS{mod(i-1, numel(c.COLORS)) + 1};
    mkr = c.MARKERS{mod(i-1, numel(c.MARKERS)) + 1};
    h = scatter(ax, x, y, 120, col, 'filled', mkr, 'MarkerEdgeColor', [1 1 1], 'LineWidth', 0.8);
    h.DisplayName = g;
    if iscell(labels)
        lab = labels{i};
    else
        lab = labels.(g);
    end
    for k = 1:numel(lab)
        xr = max(x) - min(x); yr = max(y) - min(y);
        if isempty(xr) || xr == 0, xr = 1; end
        if isempty(yr) || yr == 0, yr = 1; end
        dx = 0.012 * xr; dy = 0.012 * yr;
        if x(k) > median(x), ha = 'left'; else, ha = 'right'; dx = -dx; end
        if y(k) > median(y), va = 'bottom'; else, va = 'top'; dy = -dy; end
        text(ax, x(k) + dx, y(k) + dy, lab{k}, ...
             'FontSize', 9, 'FontName', c.FONT_EN, 'Color', [0.25 0.25 0.25], ...
             'HorizontalAlignment', ha, 'VerticalAlignment', va);
    end
end
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on'); set(ax, 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
if ~isempty(o.YLabel), ylabel(ax, o.YLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
ax.FontSize = 11; ax.FontName = c.FONT_EN;
lg = legend(ax, names, 'Interpreter', 'none', 'FontSize', 11, 'FontName', c.FONT_CN, ...
            'Location', 'eastoutside', 'Box', 'off', 'Color', 'none');
end
