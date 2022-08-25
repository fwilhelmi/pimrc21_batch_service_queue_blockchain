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
FORKS_ENABLED = 1;

% Set simulation parameters
timeout = [.1 .5 2];              % timeout in seconds for generating a block
block_size = 1:10;                % block size in number of transactions
queue_length = 10;                % number of transactions that fit the queue
lambda = [2.5 5 7.5 10 12.5 15];  % arrivals rate (UE requests)
mu = 15;                          % mining rate
nStas = 50;                       % Number of STAs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 1 BUILD THE SCENARIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1 : 2
    
    if n == 1
        FORKS_ENABLED = 0;
    elseif n == 2
        FORKS_ENABLED = 1;
    end
    
    % Generate the deployment
    deployment = GenerateDeployment(nStas);
    [C_access,~] = ComputeThroughput(deployment, 1, INTERFERENCE_MODE);
    [~,C_p2p] = ComputeThroughput(deployment, 2, INTERFERENCE_MODE);
    n_hops = 1;%deployment.nAps / mean(sum(deployment.signalApAp>deployment.ccaThreshold));

    T_prop = cell(1,length(timeout));
    T_queue = cell(1,length(timeout));
    p_fork = cell(1,length(timeout));
    n_fork = cell(1,length(timeout));
    drop_prob = cell(1,length(timeout));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% 2 GENERATE MODEL RESULTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Iterate for each timer value
    for t = 1 : length(timeout)           
        TIMER = timeout(t);
        disp(['timeout = ' num2str(TIMER)])        
        % Iterate for each value of user activity (number of requests per second)
        for l = 1 : length(lambda)                
            LAMBDA = lambda(l);
            disp(['Users arrivals (lambda) = ' num2str(LAMBDA)])
            % Iterate for each block size
            for m = 1 : length(block_size)                  
                disp(['     - Block size = ' num2str(block_size(m))])
                % Compute delays BC operation
                % - Propagation delay
                T_prop{t}(l,m) = (HEADER_LENGTH + block_size(m)*TRANSACTION_LENGTH)/mean(C_p2p) * n_hops;
                % - Queue model
                if FORKS_ENABLED
                    % Model Fork probability
                    p_fork{t}(l,m) = compute_fork_probability(T_prop{t}(l,m), mu, deployment.nAps);
                    n_fork{t}(l,m) = 1./(1-p_fork{t}(l,m));
                    % - Queue delay
                    [T_queue{t}(l,m), ~, drop_prob{t}(l,m)] = queue_model_function(LAMBDA, mu,...
                        queue_length, block_size(m), TIMER, n_fork{t}(l,m), LOGS_ENABLED);
                else
                    % Model Fork probability
                    p_fork{t}(l,m) = 0;
                    n_fork{t}(l,m) = 1./(1-p_fork{t}(l,m));
                    % - Queue delay
                    [T_queue{t}(l,m), ~, drop_prob{t}(l,m)] = queue_model_function(LAMBDA, mu, queue_length, ...
                        block_size(m), TIMER, n_fork{t}(l,m), LOGS_ENABLED);
                end                  
            end             
        end        
    end

    save(['workspace_FORKS_ENABLED_' num2str(FORKS_ENABLED) '.mat'])
   
end

%%
