%%% *********************************************************************
%%% * Blockchain-Enabled RAN Sharing for Future 5G/6G Communications    *
%%% * Authors: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)*
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * GitHub repository: ...                                            *
%%% *********************************************************************

%% FIGURE 1: SURF
filename = 'workspace_FORKS_ENABLED_0.mat';
load(filename);  
figure
for t = 1 : length(timeout)
    subplot(2,length(timeout),t)
    surf(T_queue{t})
    axis([0 11 0 6 0 2])
    hold on
end    
filename = 'workspace_FORKS_ENABLED_1.mat';
load(filename);  
for t = 1 : length(timeout)
    subplot(2,length(timeout),length(timeout)+t)
    surf(T_queue{t})
    axis([0 11 0 6 0 2])
    hold on
end  

%% FIGURE 2: BAR PLOT

filename = 'workspace_FORKS_ENABLED_0.mat';
load(filename);  
figure
subplot(1,2,1)
data1 = [mean(T_queue{1})' mean(T_queue{2})' mean(T_queue{3})'];
bar([data1], 'stacked')
ylabel('Queue delay (s)')
xlabel('Block size (kbits)')
axis([0 11 0 3.5])
xticks(1:10)
xticklabels([3:3:30])
yyaxis right
plot(p_fork{1}(1,:),'rx','linewidth',2.0,'markersize',8.0)
ylabel('Fork probability')
axis([0 11 0 1])
grid on
grid minor
set(gca, 'fontsize',16)
legend({'T_w = 0.1 s', 'T_w = 0.5 s', 'T_w = 2 s'})

filename = 'workspace_FORKS_ENABLED_1.mat';
load(filename);  
subplot(1,2,2)
data2 = [mean(T_queue{1})' mean(T_queue{2})' mean(T_queue{3})'];
bar([data2], 'stacked')
ylabel('Queue delay (s)')
xlabel('Block size (kbits)')
xticks(1:10)
xticklabels([3:3:30])
axis([0 11 0 3.5])
yyaxis right
plot(p_fork{1}(1,:),'rx','linewidth',2.0,'markersize',8.0)
ylabel('Fork probability')
axis([0 11 0 1])
grid on
grid minor
set(gca, 'fontsize',16)
legend({'T_w = 0.1 s', 'T_w = 0.5 s', 'T_w = 2 s', 'Fork prob.'})

%% 
filename = 'workspace_FORKS_ENABLED_0.mat';
load(filename);  
figure
subplot(1,2,1)
data1 = [mean(drop_prob{1})' mean(drop_prob{2})' mean(drop_prob{3})'];
bar([data1], 'stacked')
ylabel('Drop probability')
xlabel('Block size (kbits)')
axis([0 11 0 1])
xticks(1:10)
xticklabels([3:3:30])
yyaxis right
plot(p_fork{1}(1,:),'rx','linewidth',2.0,'markersize',8.0)
ylabel('Fork probability')
axis([0 11 0 1])
grid on
grid minor
set(gca, 'fontsize',16)
legend({'T_w = 0.1 s', 'T_w = 0.5 s', 'T_w = 2 s'})

filename = 'workspace_FORKS_ENABLED_1.mat';
load(filename);  
subplot(1,2,2)
data2 = [mean(drop_prob{1})' mean(drop_prob{2})' mean(drop_prob{3})'];
bar([data2], 'stacked')
ylabel('Drop probability')
xlabel('Block size (kbits)')
axis([0 11 0 1])
xticks(1:10)
xticklabels([3:3:30])
yyaxis right
plot(p_fork{1}(1,:),'rx','linewidth',2.0,'markersize',8.0)
ylabel('Fork probability')
axis([0 11 0 1])
grid on
grid minor
set(gca, 'fontsize',16)
legend({'T_w = 0.1 s', 'T_w = 0.5 s', 'T_w = 2 s', 'Fork prob.'})

%% FIGURE 3: BOXPLOT
filename = 'workspace_FORKS_ENABLED_0.mat';
load(filename); 
figure
for t = 1 : length(timeout)
    subplot(2,3,t)
    boxplot(T_queue{t})
    hold on        
    grid on
    grid minor
    set(gca, 'fontsize',14)
    axis([0 11 0 2])
end

filename = 'workspace_FORKS_ENABLED_1.mat';
load(filename); 
for t = 1 : length(timeout)
    subplot(2,3,3+t)
    boxplot(T_queue{t})
    hold on        
    grid on
    grid minor
    set(gca, 'fontsize',14)
    axis([0 11 0 2])
end