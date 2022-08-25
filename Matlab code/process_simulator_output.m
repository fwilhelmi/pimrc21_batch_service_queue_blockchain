%%% *********************************************************************
%%% * Blockchain-Enabled RAN Sharing for Future 5G/6G Communications    *
%%% * Authors: Lorenza Giupponi & Francesc Wilhelmi (fwilhelmi@cttc.cat)*
%%% * Copyright (C) 2020-2025, and GNU GPLd, by Francesc Wilhelmi       *
%%% * GitHub repository: ...                                            *
%%% *********************************************************************

% Arrays to store results
for t = 1 : length(timeout)
    total_transactions{t} = zeros(length(lambda), length(block_size));
    transactions_dropped{t} = zeros(length(lambda), length(block_size));
    drop_percentage{t} = zeros(length(lambda), length(block_size));
    num_blocks_mined_by_timeout{t} = zeros(length(lambda), length(block_size));
    mean_occupancy{t} = zeros(length(lambda), length(block_size));
    mean_delay{t} = zeros(length(lambda), length(block_size));  
    p_fork_sim{t} = zeros(length(lambda), length(block_size));  
end

% Files directory
if FORKS_ENABLED
    files_path = ['simulator_output/k=' num2str(queue_length) '_fork'];
%     files_path = ['simulator_output/forks_k=' num2str(queue_length) '_t=' num2str(timer)];
else
    files_path = ['simulator_output/k=' num2str(queue_length) '_no_fork'];
%     files_path = ['simulator_output/k=' num2str(queue_length) '_t=' num2str(timer)];
end
files_dir = dir([files_path '/*.txt']);

% Iterate for each file in the directory
for i = 1 : length(files_dir)
    % Get the name of the file being analyzed
    file_name = files_dir(i).name;  
    % Find the parameters used (timer, lambda & block size)
    % - Timer
    split01 = strsplit(file_name,'_');
    ix = 3;
    if FORKS_ENABLED, ix = ix+1; end
    split02 = strsplit(split01{ix},'t');
    t = str2double(split02{2});
    ix_t = find(timeout==t);
    % - Lambda
    split1 = strsplit(file_name,'_');
    ix = 4;
    if FORKS_ENABLED, ix = ix+1; end
    split2 = strsplit(split1{ix},'l');
    l = str2double(split2{2});
    ix_l = find(lambda==l);
    % - Block size
    ix = 5;
    if FORKS_ENABLED, ix = ix+1; end
    split3 = strsplit(split1{ix},'s');
    split4 = strsplit(split3{2},'.');
    s = str2double(split4{1});
    ix_s = find(block_size==s);
    % Read the file
    if isempty(ix_t) || isempty(ix_l) || isempty(ix_s)
        % Skip this file
    else
        file_data = fopen([files_path '/' file_name]);
        A = textscan(file_data,'%s','Delimiter',';');
        B = str2double(A{:});    
        % Store results to variables
        total_transactions{ix_t}(ix_l,ix_s) = B(2);
        transactions_dropped{ix_t}(ix_l,ix_s) = B(3);
        drop_percentage{ix_t}(ix_l,ix_s) = B(4);
        num_blocks_mined_by_timeout{ix_t}(ix_l,ix_s) = B(5);
        mean_occupancy{ix_t}(ix_l,ix_s) = B(6);
        mean_delay{ix_t}(ix_l,ix_s) = B(7);     
        if FORKS_ENABLED
            p_fork_sim{ix_t}(ix_l,ix_s) = B(8);  
        end
    end
end

% Save workspace
save('tmp/simulator_output')