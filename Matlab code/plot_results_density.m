%%% *********************************************************************
%%% * Blockchain-Enabled RAN Sharing for Future 5G/6G Communications    *
%%% * Authors: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)*
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * GitHub repository: ...                                            *
%%% *********************************************************************
clear all
clc

% Files directory
filename_root = 'workspace_density_forks';

% Enable/disable Forks
FORKS_ENABLED = 0;

% Simulation parameters
timeout = [.1 .5 2];           % timeout in seconds for generating a block
block_size = [1:10];           % block size in number of transactions
queue_length = 10;             % number of transactions that fit the queue
lambda = 7.5;                   % arrivals rate (UE requests)
mu = 15;                       % mining rate
num_stas = 5:5:50;%1:10:100;                      % Number of STAs
approach = 2;
nRepetitions = 25;

% figure
for t_ix = 1 : length(timeout)
    % Iterate for each file in the directory
    
    for approach = 1 : 2
    
        for d = 1 : 6
        %     TOTAL_DELAY(:,d) = zeros(length(timeout)*length(block_size)*nRepetitions, 1);
            aux_delay = [];
            for i = 1 : 10
                load([filename_root num2str(FORKS_ENABLED) '_approach' num2str(approach) ...
                    '_r' num2str(i) '.mat']);
                aux_delay = [aux_delay total_delay{d}(t_ix,1:2)]; 
            end
            delay_per_density{d} = aux_delay;
            %delay{i} = total_delay;
        end
        y = num2cell(1:numel(delay_per_density));
        x = cellfun(@(x, y) [x(:) y*ones(size(x(:)))], delay_per_density, y, 'UniformOutput', 0); % adding labels to the cells
        X = vertcat(x{:});

        if approach == 1
        subplot(1,3,t_ix)
        boxplot(X(:,1), X(:,2))
        set(gca,'fontsize',14)
        title(['T_w = ' num2str(timeout(t_ix)) ' s'])
        xlabel('Num. of STAs')
        ylabel('End-to-end latency (s)')
        xticks(1:length(num_stas))
        xticklabels(5:5:100)
        %axis([0, length(num_stas)+1, 0, .6])
        grid on
        grid minor
        hold on
        elseif approach == 2
            mean_d = cellfun(@mean,delay_per_density,'uni',0);
            std_d = cellfun(@std,delay_per_density,'uni',0); 
            hold on
            plot(cell2mat(mean_d),'r--x','linewidth',2.0,'markersize',8)        
    %         errorbar(cell2mat(mean_d),cell2mat(std_d))
        end
    
    end
    
end
%bar(delay{1})