%%% *********************************************************************
%%% * Batch-service queue model for Blockchain                          *
%%% * By: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)     *
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * Repo.: bitbucket.org/francesc_wilhelmi/model_blockchain_delay     *
%%% *********************************************************************

% FILE DESCRIPTION: this file is used to test the batch service queue model. 
% Customizable inputs can be provided for specific cases.

clc

constants
conf_environment

% Enable/disable plots and logs
PLOTS_ENABLED = 1;
LOGS_ENABLED = 1;

% Enable/disable Forks
FORKS_ENABLED = 0;

% Set simulation parameters
T_WAIT = 10;          % timeout in seconds for generating a block
block_size = 2;       % block size in number of transactions
queue_length = 10;    % number of transactions that fit the queue
lambda = 2.5;         % arrivals rate (UE requests)
mu = MINING_RATE;

% Model
[queue_delay, queue_length_model] = queue_model_function(lambda, mu, ...
    queue_length, block_size, T_WAIT, ones(1,length(block_size)), LOGS_ENABLED);

% DELAY
disp([' - Queue delay: ' num2str(queue_delay) ' s'])
% OCCUPANCY
disp([' - Queue length: ' num2str(queue_length_model)])