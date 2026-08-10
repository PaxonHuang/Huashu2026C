function mmflow_draw(fig, boxes, arrows, varargin)
% mmflow_draw - draw a flowchart using annotations (all coords normalized 0-1).
%   boxes: n x 4 matrix [x y w h], each row is a box in normalized figure coords
%   arrows: m x 4 matrix [x1 y1; x2 y2], waypoints of an m-segment polyline arrow
%           OR m x 2k matrix where each row is [x1 y1 x2 y2 ... xk yk] defining (k-1) segments
%   Name-Value: 'Texts' cell(n,1) of label strings
%               'Colors' n x 3 RGB per box, OR single RGB for all boxes
%               'TextColors' n x 3 RGB per box, OR single RGB
%               'ArrowColors' m x 3 RGB per arrow, OR single RGB (default [0.4 0.4 0.4])
%               'MaskBoxes' logical: if true, draw white mask segments at arrow endpoints (default true)
p = inputParser;
addParameter(p, 'Texts', {}, @iscell);
addParameter(p, 'Colors', [0.388 0.094 0.475]);
addParameter(p, 'TextColors', [1 1 1]);
addParameter(p, 'ArrowColors', [0.4 0.4 0.4]);
addParameter(p, 'MaskBoxes', true, @islogical);
parse(p, varargin{:});
o = p.Results;
nb = size(boxes, 1);
na = size(arrows, 1);
% broadcast single RGB
if size(o.Colors, 1) == 1, o.Colors = repmat(o.Colors, nb, 1); end
if size(o.TextColors, 1) == 1, o.TextColors = repmat(o.TextColors, nb, 1); end
if size(o.ArrowColors, 1) == 1, o.ArrowColors = repmat(o.ArrowColors, na, 1); end
% draw boxes
for i = 1:nb
    x = boxes(i, 1); y = boxes(i, 2); w = boxes(i, 3); h = boxes(i, 4);
    col = o.Colors(i, :);
    annotation(fig, 'rectangle', 'Position', [x y w h], 'FaceColor', col, ...
              'EdgeColor', max(0, col - 0.1), 'LineWidth', 1.2);
    tx = x + w / 2; ty = y + h / 2;
    if i <= numel(o.Texts) && ~isempty(o.Texts{i})
        annotation(fig, 'textbox', 'Position', [x y w h], 'String', o.Texts{i}, ...
                  'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                  'FontSize', 11, 'FontName', 'Microsoft YaHei', 'FontWeight', 'bold', ...
                  'Color', o.TextColors(i, :), 'EdgeColor', 'none', 'FitBoxToText', 'off');
    end
end
% draw arrows
for a = 1:na
    pts = arrows(a, :);
    npts = numel(pts) / 2;
    xs = pts(1:2:end); ys = pts(2:2:end);
    col = o.ArrowColors(a, :);
    for s = 1:npts-1
        % white mask segment behind arrow
        if o.MaskBoxes
            annotation(fig, 'line', 'Position', [xs(s) ys(s) xs(s+1)-xs(s) ys(s+1)-ys(s)], ...
                      'Color', [1 1 1], 'LineWidth', 5, 'LineStyle', '-');
        end
        annotation(fig, 'arrow', 'Position', [xs(s) ys(s) xs(s+1)-xs(s) ys(s+1)-ys(s)], ...
                  'Color', col, 'LineWidth', 1.8, 'HeadLength', 8, 'HeadWidth', 8);
    end
end
end
