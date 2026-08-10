function fig = mmgantt(regions, types, barscells, varargin)
% mmgantt - lane-based Gantt chart (mirrors render_gantt).
%   regions: cellstr of sorted execution regions
%   types:   cellstr of task types in fixed display order
%   barscells: nr x nt cell array; each entry is a nx2 matrix [StartHour EndHour]
%              for every bar in that lane (empty = no bars).
p = inputParser;
addParameter(p, 'XLabel', 'Time / h', @ischar);
addParameter(p, 'FigSize', [14 10]);
addParameter(p, 'StartHour', [], @isnumeric);
addParameter(p, 'EndHour', [], @isnumeric);
parse(p, varargin{:});
o = p.Results;

c = mmconfig();
typeColor = containers.Map(types, c.COLORS(1:numel(types)));
typeShort = containers.Map();
for t = 1:numel(types)
    if strcmp(types{t}, 'RealTimeInference'), typeShort(types{t}) = 'RT'; end
    if strcmp(types{t}, 'BatchInference'),    typeShort(types{t}) = 'Batch'; end
    if strcmp(types{t}, 'AITraining'),        typeShort(types{t}) = 'Train'; end
end
nr = numel(regions); nt = numel(types);
lanes = cell(1, nr*nt);
li = 0;
for i = 1:nr
    for j = 1:nt
        li = li + 1;
        if isKey(typeShort, types{j}), ts = typeShort(types{j}); else, ts = types{j}; end
        lanes{li} = sprintf('%s / %s', regions{i}, ts);
    end
end
% gather bounds
allbars = [];
for i = 1:nr
    for j = 1:nt
        allbars = [allbars; barscells{i,j}]; %#ok<AGROW>
    end
end
if ~isempty(o.StartHour), sh = o.StartHour; else, sh = min(allbars(:,1)); end
if ~isempty(o.EndHour), eh = o.EndHour; else, eh = max(allbars(:,2)); end
if isempty(sh), sh = 0; end
if isempty(eh), eh = 1; end

fig = figure('Visible', 'off', 'Position', [50 50 round(o.FigSize(1)*100) round(o.FigSize(2)*100)]);
ax = axes('Parent', fig);
hold(ax, 'on');
for i = 1:nr
    for j = 1:nt
        B = barscells{i, j};
        if isempty(B), continue; end
        laneidx = (i-1)*nt + j - 1;
        for k = 1:size(B, 1)
            s = max(B(k, 1), sh); e = min(B(k, 2), eh);
            if e <= s, continue; end
            rectangle(ax, 'Position', [s, laneidx+0.15, e-s, 0.7], ...
                      'FaceColor', typeColor(types{j}), 'EdgeColor', [1 1 1], 'LineWidth', 0.3);
        end
    end
end
set(ax, 'YTick', (0:numel(lanes)-1) + 0.5, 'YTickLabel', lanes, 'FontSize', 9, 'FontName', c.FONT_EN);
set(ax, 'XLim', [sh eh]);
grid(ax, 'on'); ax.GridAlpha = 0.4; ax.GridLineStyle = ':'; ax.Layer = 'bottom';
box(ax, 'on'); set(ax, 'LineWidth', 1.1, 'TickDir', 'in');
if ~isempty(o.XLabel), xlabel(ax, o.XLabel, 'FontSize', 13, 'FontName', c.FONT_CN); end
hp = zeros(1, nt);
for j = 1:nt
    hp(j) = patch(ax, NaN, NaN, typeColor(types{j}), 'DisplayName', types{j}, 'EdgeColor', 'none');
end
lg = legend(ax, hp, types, 'Interpreter', 'none', 'FontSize', 10, 'FontName', c.FONT_CN, ...
            'Location', 'bestoutside', 'Box', 'off', 'Color', 'none');
end
