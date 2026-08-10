% gen_flows.m - MATLAB redraw of 5 flowcharts (roadmap + q1-q4 flows)
addpath('E:/mm_redraw/scripts');
set(0, 'DefaultAxesFontName', 'Microsoft YaHei');
c = mmconfig();
BLUE   = c.BLUE;
TEAL   = c.TEAL;       % [0.000 0.510 0.502]
ORANGE = c.ORANGE;     % [0.804 0.494 0.173]
GREY   = c.GREYTXT;    % [0.400 0.400 0.400]
WHITE  = [1 1 1];
M = 0.05;  % normalized margin

%% ========== 1. Roadmap (fig_roadmap) ==========
% Canvas 1100x600. 7 boxes, 9 arrows (EDA fans to Q1-Q4, each Q fans back)
fprintf('flow: fig_roadmap\n');
fig = figure('Visible','off','Position',[50 50 1100 600],'Color','white');
% canvas-to-norm conversion
% nx = M + canvas_x / 1100
% ny = M + (600 - canvas_y - 45) / 600
bw  = 160/1100;  bh  = 45/600;
n1x = M+ 40/1100;  n1y = M+(600-160-45)/600;   % 数据预处理 (40,160)
n2x = M+260/1100;  n2y = n1y;                    % EDA (260,160)
n3x = M+500/1100;  n3y = M+(600- 40-45)/600;    % Q1 (500,40)
n4x = n3x;         n4y = M+(600-120-45)/600;    % Q2 (500,120)
n5x = n3x;         n5y = M+(600-200-45)/600;    % Q3 (500,200)
n6x = n3x;         n6y = M+(600-280-45)/600;    % Q4 (500,280)
n7x = M+740/1100;  n7y = n1y;                    % 敏感性 (740,160)

boxes = [n1x n1y bw bh; n2x n2y bw bh; n3x n3y bw bh; n4x n4y bw bh;
         n5x n5y bw bh; n6x n6y bw bh; n7x n7y bw bh];
cols  = [BLUE; BLUE; TEAL; TEAL; TEAL; TEAL; BLUE];
texts = {'数据预处理','EDA','Q1 任务调度建模','Q2 任务调度优化',...
         'Q3 储能调度','Q4 多目标优化','敏感性分析'};

% midpoints for L-shaped arrows
yM  = n1y + bh/2;                            % center-y of row1 boxes
yQ  = [n3y+bh/2, n4y+bh/2, n5y+bh/2, n6y+bh/2];  % center-y of Q1..Q4
mx1 = (n1x+bw + n2x)/2;                     % between 数据预处理 and EDA
mx2 = (n2x+bw + n3x)/2;                     % between EDA and Q-column
mx3 = (n3x+bw + n7x)/2;                     % between Q-column and 敏感性

arrs = [];
% e1: 数据预处理 → EDA (horizontal, 3 waypoints padded to 4 with zero)
arrs(1,:) = [n1x+bw yM mx1 yM  n2x yM  0 0];
% e2-e5: EDA → Q1..Q4 (horizontal then vertical down, 4 waypoints)
for q = 1:4
    arrs(end+1,:) = [n2x+bw yM mx2 yM  mx2 yQ(q)  n3x yQ(q)]; %#ok
end
% e6-e9: Q1..Q4 → 敏感性 (horizontal then vertical up, 4 waypoints)
for q = 1:4
    arrs(end+1,:) = [n3x+bw yQ(q) mx3 yQ(q)  mx3 yM  n7x yM]; %#ok
end

mmflow_draw(fig, boxes, arrs, 'Texts',texts, 'Colors',cols, 'ArrowColors',GREY);
mmsavepdf(fig, 'fig_roadmap');

%% ========== 2. Q1 flow (fig_flow_q1) ==========
% Canvas 700x900. 11 boxes vertical chain. Blue=start/end, Teal=process, Orange=decision
fprintf('flow: fig_flow_q1\n');
fig = figure('Visible','off','Position',[50 50 700 900],'Color','white');
bw  = 200/700;  bh  = 40/900;
cx  = M + 320/700;        % box x (centered horizontally within canvas)
bcx = cx + bw/2;          % center x for arrows

q1_ys = [60 140 220 300 380 460 540 620 700 780 860];
q1_ny = M + (900 - q1_ys - 40)/900;   % 11 normalized y positions
boxes = repmat([cx 0 bw bh], 11, 1);
boxes(:,2) = q1_ny';

q1_cols = [BLUE; TEAL; TEAL; BLUE; ORANGE; TEAL; BLUE; TEAL; TEAL; ORANGE; BLUE];
q1_texts = {'读取任务轨迹数据','聚合18条GPU-h序列','构造滞后特征矩阵',...
            '岭回归训练+季节朴素法对比','验证集选模(2352-2375)','测试窗预测(2376-2399)',...
            '读取末端实际538任务','EDF排序','候选集枚举(容量/时延/截止期)',...
            '容量压力最小化选择','输出甘特图/GPU利用率/迁移矩阵'};

arrs = zeros(10,4);
for i = 1:10
    y1 = q1_ny(i) + bh/2;
    y2 = q1_ny(i+1) + bh/2;
    arrs(i,:) = [bcx y1 bcx y2];
end

mmflow_draw(fig, boxes, arrs, 'Texts',q1_texts, 'Colors',q1_cols, 'ArrowColors',GREY);
mmsavepdf(fig, 'fig_flow_q1');

%% ========== 3. Q2 flow (fig_flow_q2) ==========
% Canvas 700x900. 7 boxes in main chain + box8 (回退) offset right. Diamond = box5.
fprintf('flow: fig_flow_q2\n');
fig = figure('Visible','off','Position',[50 50 700 900],'Color','white');
bw1 = 200/700;  bh = 40/900;
cx  = M + 320/700;
bcx = cx + bw1/2;

% main chain boxes 1-4, 6-7 (standard size), box5 (decision, slightly wider/taller)
q2_ys = [60 140 220 300 0 490 570];  % 0 = placeholder for box5
q2_ny = M + (900 - q2_ys(1:4) - 40)/900;
q2_ny(5) = M + (900 - 380 - 60)/900;                    % box5 y (60px tall)
q2_ny(6:7) = M + (900 - q2_ys(6:7) - 40)/900;

n5w = 160/700;  n5h = 60/900;
n5x = M + 270/700;   % offset left (wider decision box)
n8w = 130/700;  n8h = 40/900;
n8x = M + 460/700;   % offset right
n8y = M + (900 - 390 - 40)/900;

boxes = [cx q2_ny(1) bw1 bh; cx q2_ny(2) bw1 bh; cx q2_ny(3) bw1 bh; cx q2_ny(4) bw1 bh;
         n5x q2_ny(5) n5w n5h;
         cx q2_ny(6) bw1 bh; cx q2_ny(7) bw1 bh;
         n8x n8y n8w n8h];
q2_cols = [BLUE; TEAL; TEAL; ORANGE; ORANGE; TEAL; BLUE; TEAL];
q2_texts = {'读取50000任务','候选集压缩(时延/截止期/容量过滤)',...
            '任务排序(EDF+GPU-h)','增量目标评分','接受/回溯',...
            '约束审计(GPU/IT/设施/时延)','输出KPI与迁移矩阵','回退至增量评分'};

% e1-e6: main chain vertical arrows (2 waypoints → padded to 6 values)
arrs = [];
arrs(1,:) = [bcx q2_ny(1)+bh/2 bcx q2_ny(2)+bh/2 0 0];
arrs(2,:) = [bcx q2_ny(2)+bh/2 bcx q2_ny(3)+bh/2 0 0];
arrs(3,:) = [bcx q2_ny(3)+bh/2 bcx q2_ny(4)+bh/2 0 0];
n5cx = n5x + n5w/2;  n5cy = q2_ny(5) + n5h/2;
arrs(4,:) = [bcx q2_ny(4)+bh/2 n5cx n5cy 0 0];
arrs(5,:) = [n5cx n5cy bcx q2_ny(6)+bh/2 0 0];
arrs(6,:) = [bcx q2_ny(6)+bh/2 bcx q2_ny(7)+bh/2 0 0];
n8cy = n8y + n8h/2;
arrs(7,:) = [n5x+n5w n5cy n8x n8cy 0 0];
arrs(8,:) = [n8x n8cy bcx n8cy bcx q2_ny(4)+bh/2]; % 3 waypoints, back-edge

mmflow_draw(fig, boxes, arrs, 'Texts',q2_texts, 'Colors',q2_cols, 'ArrowColors',GREY);
mmsavepdf(fig, 'fig_flow_q2');

%% ========== 4. Q3 flow (fig_flow_q3) ==========
% Canvas 700x900. 7 boxes vertical. Last box slightly taller.
fprintf('flow: fig_flow_q3\n');
fig = figure('Visible','off','Position',[50 50 700 900],'Color','white');
bw  = 200/700;  bh = 40/900;  bh2 = 50/900;
cx  = M + 320/700;  bcx = cx + bw/2;

q3_ys = [60 140 220 300 380 460 540];
q3_ny = M + (900 - q3_ys - 40)/900;
q3_ny(7) = M + (900 - 540 - 50)/900;   % box7 is 50px tall

boxes = [cx q3_ny(1) bw bh; cx q3_ny(2) bw bh; cx q3_ny(3) bw bh;
         cx q3_ny(4) bw bh; cx q3_ny(5) bw bh; cx q3_ny(6) bw bh;
         cx q3_ny(7) bw bh2];
q3_cols = [BLUE; TEAL; ORANGE; TEAL; TEAL; ORANGE; BLUE];
q3_texts = {'固定附件基准AI负荷','读取储能参数(容量/功率/效率)',...
            '24h边际能价阈值计算','充电/放电决策','SOC前向投影修复',...
            '终端SOC≥初始SOC约束','输出净购售电成本/SOC轨迹/新能源利用率'};

arrs = zeros(6,4);
for i = 1:6
    h_i = bh; if i==6, h_i = bh2; end   % box7 uses bh2 but box6 is bh
    arrs(i,:) = [bcx q3_ny(i)+bh/2 bcx q3_ny(i+1)+bh/2];
end

mmflow_draw(fig, boxes, arrs, 'Texts',q3_texts, 'Colors',q3_cols, 'ArrowColors',GREY);
mmsavepdf(fig, 'fig_flow_q3');

%% ========== 5. Q4 flow (fig_flow_q4) ==========
% Canvas 850x900. Top 5 boxes wide, bottom 3 narrower.
fprintf('flow: fig_flow_q4\n');
fig = figure('Visible','off','Position',[50 50 850 900],'Color','white');
bw1 = 240/850;  bh = 40/900;
cx1 = M + 340/850;  bcx1 = cx1 + bw1/2;

bw2 = 160/850;
cx2 = M + 390/850;  bcx2 = cx2 + bw2/2;

q4_ys1 = [60 150 240 330 420];       % top 5
q4_ys2 = [510 590 670];              % bottom 3
q4_ny1 = M + (900 - q4_ys1 - 40)/900;
q4_ny2 = M + (900 - q4_ys2 - 40)/900;

boxes = [cx1 q4_ny1(1) bw1 bh; cx1 q4_ny1(2) bw1 bh; cx1 q4_ny1(3) bw1 bh;
         cx1 q4_ny1(4) bw1 bh; cx1 q4_ny1(5) bw1 bh;
         cx2 q4_ny2(1) bw2 bh; cx2 q4_ny2(2) bw2 bh; cx2 q4_ny2(3) bw2 bh];
q4_cols = [BLUE; TEAL; TEAL; TEAL; TEAL; ORANGE; TEAL; BLUE];
q4_texts = {'交替分解：任务调度→储能派发→任务调度...','扫描四组目标权重(经济优先/均衡/低碳优先/综合)',...
            '扫描三类电价机制(原始分时/平价化/峰谷差扩大)','扫描三档新能源出力(-20%/基准/+20%)',...
            '扫描四档碳预算','非支配判定','情景审计','输出Pareto前沿'};

arrs = [];
% top chain: 1→2→3→4→5
for i = 1:4
    arrs(end+1,:) = [bcx1 q4_ny1(i)+bh/2 bcx1 q4_ny1(i+1)+bh/2]; %#ok
end
% 5→6 (cross from wide to narrow section, vertical)
arrs(end+1,:) = [bcx1 q4_ny1(5)+bh/2 bcx2 q4_ny2(1)+bh/2]; %#ok
% 6→7, 7→8
arrs(end+1,:) = [bcx2 q4_ny2(1)+bh/2 bcx2 q4_ny2(2)+bh/2]; %#ok
arrs(end+1,:) = [bcx2 q4_ny2(2)+bh/2 bcx2 q4_ny2(3)+bh/2]; %#ok

mmflow_draw(fig, boxes, arrs, 'Texts',q4_texts, 'Colors',q4_cols, 'ArrowColors',GREY);
mmsavepdf(fig, 'fig_flow_q4');

fprintf('All 5 flowcharts done\n');
