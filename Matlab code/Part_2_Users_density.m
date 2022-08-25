%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used to analyze the performance of BC
% wireless networks.

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
FORKS_ENABLED = 0;

% Set simulation parameters
timeout = [.1 .5 2];           % timeout in seconds for generating a block
block_size = [1 2];           % block size in number of transactions
queue_length = 10;             % number of transactions that fit the queue
lambda = 7.5;                   % arrivals rate (UE requests)
mu = 15;                       % mining rate

num_stas = 5:5:50;%1:10:100;                      % Number of STAs

numApproaches = 1;
nRepetitions = 10;

for r = 1 : nRepetitions

for k = 2 : 2%numApproaches

    total_delay = cell(1,length(num_stas));
    T_tr = cell(1,length(num_stas));
    T_p2p = cell(1,length(num_stas));
    T_prop = cell(1,length(num_stas));
    T_mine = cell(1,length(num_stas));
    T_queue = cell(1,length(num_stas));
    p_fork = cell(1,length(num_stas));
    n_fork = cell(1,length(num_stas));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 1 BUILD THE SCENARIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1 : length(num_stas)
    
    disp(['num_stas = ' num2str(num_stas(n))])
    
    % Generate the deployment
    deployment = GenerateDeployment(num_stas(n));
    [C_access,~] = ComputeThroughput(deployment, 1, INTERFERENCE_MODE);
    
    if k == 1
        [~,C_p2p] = ComputeThroughput(deployment, 1, INTERFERENCE_MODE);
    elseif k == 2
        [~,C_p2p] = ComputeThroughput(deployment, 2, INTERFERENCE_MODE);
%     elseif k == 3
%         [~,C_p2p] = ComputeThroughput(deployment, 2, INTERFERENCE_MODE);
    end
    n_hops = deployment.nAps / mean(sum(deployment.signalApAp>deployment.ccaThreshold));
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% 2 GENERATE MODEL RESULTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Iterate for each timer value
    for t = 1 : length(timeout)   
        
        TIMER = timeout(t);
        disp(['  + TIMER = ' num2str(TIMER)])
        
        % Iterate for each value of user activity (number of requests per second)
        for l = 1 : length(lambda)    
            
            LAMBDA = lambda(l);
            disp(['    * Users arrivals (lambda) = ' num2str(LAMBDA)])
            % Iterate for each block size
            for m = 1 : length(block_size)  
                
                disp(['      - Block size = ' num2str(block_size(m))])
                % Compute delays BC operation
                % - Delay STA-Miner
                T_tr{n}(t,m) = (HEADER_LENGTH + TRANSACTION_LENGTH) / mean(C_access);
                % - Delay P2P
                T_p2p{n}(t,m) = (HEADER_LENGTH + TRANSACTION_LENGTH) / mean(C_p2p)*n_hops;
                % - Propagation delay
                T_prop{n}(t,m) = (HEADER_LENGTH + block_size(m)*TRANSACTION_LENGTH)/mean(C_p2p) * n_hops;
                % - Queue model
                if FORKS_ENABLED
                    % Model Fork probability
                    p_fork{n}(t,m) = compute_fork_probability(T_prop{n}(t,m), mu, deployment.nAps);
                    n_fork{n}(t,m) = 1./(1-p_fork{n}(t,m));
                    % - Mining delay
                    T_mine{n}(t,m) = 1/(mu*deployment.nAps);
                    % - Queue delay
                    [T_queue{n}(t,m), ~] = queue_model_function(LAMBDA, mu*deployment.nAps,...
                        queue_length, block_size(m), TIMER, n_fork{n}(t,m), LOGS_ENABLED);
                    % Total delay (with forks)
                    total_delay{n}(t,m) = T_tr{n}(t,m) + T_p2p{n}(t,m) + ...
                        n_fork{n}(t,m)*(T_queue{n}(t,m) + T_mine{n}(t,m) + T_prop{n}(t,m));
                else
                    % Model Fork probability
                    p_fork{n}(t,m) = 0;
                    n_fork{n}(t,m) = 1./(1-p_fork{n}(t,m));
                    % - Mining delay
                    T_mine{n}(t,m) = 1/mu;
                    % - Queue delay
                    [T_queue{n}(t,m), ~] = queue_model_function(LAMBDA, mu, queue_length, ...
                        block_size(m), TIMER, n_fork{n}(t,m), LOGS_ENABLED);
                    % Total delay (without forks)
                    total_delay{n}(t,m) = T_tr{n}(t,m) + T_p2p{n}(t,m) + ...
                        T_queue{n}(t,m) + T_mine{n}(t,m) + T_prop{n}(t,m);
                end   
                
            end 
            
        end
        
    end
   
end

save(['workspace_density_forks' num2str(FORKS_ENABLED) '_approach' num2str(k) '_r' num2str(r) '.mat'])

end

end


%%
for k = 1 : 1
    load(['workspace_density_forks' num2str(FORKS_ENABLED) '_approach' num2str(k) '.mat'])
    figure
    for t = 1 : 2
        subplot(1,2,t)
        aux_d = [];
        for n = 1 : length(num_stas)        
            %aux_d = [aux_d; total_delay{n}(2,5)];
            aux_d = [aux_d total_delay{n}(t,:)'];
        end
        if k == 1
            plot(mean(aux_d))
            errorbar(mean(aux_d),std(aux_d))
            hold on
        elseif k >= 2
            plot(mean(total_delay(:,:,1)'), '--', 'linewidth', 2.0)
        end
        grid on
        grid minor
        xlabel('Num. of STAs')
        ylabel('Confirmation delay (s)')
        set(gca,'fontsize',14)
    end    
end
% legend({'Dedicated 11ax links'})
