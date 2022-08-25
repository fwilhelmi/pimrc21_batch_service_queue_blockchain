%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************
 
% FILE DESCRIPTION: this file is used to validate the batch service queue
% model for different system parameters. Results from a simulator are used
% for the validation.
 
clear
close all
clc
 
tic % Measure the time of a single simulation
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 0 PREPARE THE ENVIRONMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Load constants
constants
conf_environment
 
% Enable/disable plots and logs
PLOTS_ENABLED = 1;
LOGS_ENABLED = 0;
 
% Enable/disable Forks
FORKS_ENABLED = 1;
 
% Set simulation parameters
timeout = [.1 .5 2];                 % timeout in seconds for generating a block
block_size = 1:10;                   % block size in number of transactions
queue_length = 10;                  % number of transactions that fit the queue
lambda = [2.5 5 7.5 10 12.5 15];    % arrivals rate (UE requests)
mu = 15;                            % mining rate

n_hops = 1;
n_miners = 19;
C_p2p = 10e6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 1 BUILD THE SCENARIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
total_delay = cell(1,length(timeout));
T_tr = cell(1,length(timeout));
T_p2p = cell(1,length(timeout));
T_prop = cell(1,length(timeout));
T_mine = cell(1,length(timeout));
T_queue = cell(1,length(timeout));
p_fork = cell(1,length(timeout));
n_fork = cell(1,length(timeout));
 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 2 GENERATE MODEL RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate for each timer value
for t = 1 : length(timeout)   
    TIMER = timeout(t);
    disp(['Timer = ' num2str(TIMER)])
    % Iterate for each value of user activity (number of requests per second)
    for l = 1 : length(lambda)    
        LAMBDA = lambda(l);
        disp(['  * Users arrivals (lambda) = ' num2str(LAMBDA)])
        % Iterate for each block size
        for m = 1 : length(block_size)                
            disp(['     - Block size = ' num2str(block_size(m))])
            % - Propagation delay
            T_prop{t}(l,m) = (HEADER_LENGTH + block_size(m)*TRANSACTION_LENGTH)/C_p2p * n_hops;
            % - Queue model
            if FORKS_ENABLED
                % Model Fork probability
                p_fork{t}(l,m) = compute_fork_probability(T_prop{t}(l,m), mu, n_miners);
                n_fork{t}(l,m) = 1/(1-p_fork{t}(l,m));      
                % - Queue delay
                [T_queue{t}(l,m), ~] = queue_model_function(LAMBDA, mu*n_miners,...
                    queue_length, block_size(m), TIMER, n_fork{t}(l,m), LOGS_ENABLED);
            else
                % Model Fork probability
                p_fork{t}(l,m) = 0;
                n_fork{t}(l,m) = 1./(1-p_fork{t}(l,m));
                % - Queue delay
                [T_queue{t}(l,m), ~] = queue_model_function(LAMBDA, mu, queue_length, ...
                    block_size(m), TIMER, n_fork{t}(l,m), LOGS_ENABLED);
            end            
        end % end "for"        
    end
end    
save(['workspace_sta.mat'])    
 
% Save workspace
save('model_output')
 
%% Load sim. output
process_simulator_output
 
% Main plot with validations
for i = 1 : 3
    fig = figure;
    surf(T_queue{i}(1:4,1:5),'FaceAlpha',0.7)
    hold on
    mesh(mean_delay{i}(1:4,1:5),'FaceAlpha',0,'EdgeColor','r','marker','o','LineStyle','none','linewidth',2,'markersize',10)
    % surf(mean_delay{1})
    xlabel('S^B (Kbits)')
    ylabel('\lambda (tps)')
    zlabel('Total delay (s)')
    grid on
    grid minor
    set(gca,'fontsize',22,'fontname','times')
    xticks(1:length(block_size))
    xticklabels(3.*(1:length(block_size)))
    yticks(1:length(lambda))
    yticklabels(lambda)
    save_figure(fig, ['surf_total_delay_FORKS_ENABLED_' num2str(FORKS_ENABLED) '_' num2str(i)], '')
end

 
%% Plot additional results
PlotDelaySimVsModel()