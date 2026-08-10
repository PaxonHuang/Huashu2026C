function mmsavepdf(fig, name)
% mmsavepdf - export figure as vector PDF + 600dpi PNG, then close.
c = mmconfig();
if nargin < 2
    error('mmsavepdf requires a figure and a name');
end
set(fig, 'Renderer', 'painters');
out_pdf = fullfile(c.FIG_DIR, [name '.pdf']);
exportgraphics(fig, out_pdf, 'ContentType', 'vector');
out_png = fullfile(c.FIG_DIR, [name '.png']);
exportgraphics(fig, out_png, 'Resolution', 600);
fprintf('  saved %s\n', name);
close(fig);
end
