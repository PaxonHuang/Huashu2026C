function s = mmconfig()
% mmconfig - shared style config: palette, font, paths (mirrors plot_style.py)
s.FONT    = 'Times New Roman';   % primary font (English-only labels)
s.FONT_CN = 'Times New Roman';   % kept for API compatibility; resolves to same font
s.FONT_EN = 'Times New Roman';   % English, numbers, tick labels
% Nature Reviews palette: blue red green purple teal crimson
s.BLUE   = [0.231, 0.286, 0.573];
s.RED    = [0.933, 0.000, 0.000];
s.GREEN  = [0.000, 0.545, 0.271];
s.PURPLE = [0.388, 0.094, 0.475];
s.TEAL   = [0.000, 0.510, 0.502];
s.CRIMSON= [0.733, 0.000, 0.129];
s.ORANGE = [0.804, 0.494, 0.173];
s.GREY   = [0.361, 0.541, 0.541];
s.COLORS = {s.BLUE, s.RED, s.GREEN, s.PURPLE, s.TEAL, s.CRIMSON};
s.LINESTYLES  = {'-', '--', ':', '-.'};
s.MARKERS     = {'o', 's', 'd', '^', 'v', '>'};
s.DARKTXT  = [0.200, 0.200, 0.200];
s.GREYTXT  = [0.400, 0.400, 0.400];
s.LIGHTGREY = [0.941, 0.941, 0.941];
s.DATA_DIR  = 'E:/mm_redraw/data';
s.FIG_DIR   = 'E:/mm_redraw/figs';
end
