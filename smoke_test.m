% Smoke test: Chinese font + vector PDF export via WSL interop
set(0, 'DefaultAxesFontName', 'Microsoft YaHei');
f = figure('Visible', 'off', 'Position', [100 100 600 400]);
x = 0:0.1:2*pi;
plot(x, sin(x), 'Color', [0.231 0.286 0.573], 'LineWidth', 2);
hold on;
plot(x, cos(x), 'Color', [0.933 0 0], 'LineWidth', 2);
xlabel('预测窗口相对时刻 / h（2376=0）', 'FontSize', 12);
ylabel('GPU-h', 'FontSize', 12);
title('冒烟测试：微软雅黑中文渲染');
legend({'预测值', '实际值'}, 'Location', 'best');
grid on;
out = 'E:/mm_redraw/figs/_smoke_test.pdf';
exportgraphics(f, out, 'ContentType', 'vector');
disp(['SMOKE_OK ', out]);
d = dir(out);
disp(['SIZE ', num2str(d.bytes)]);
close(f);
exit(0);
