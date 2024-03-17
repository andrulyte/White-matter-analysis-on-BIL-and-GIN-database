% Directory containing the npy files
npy_dir = '/Users/neuro-240/Documents/BIL_and_GIN_Visit/streamline_count_matrices/connectivity_matrices_of_interest';

% Output .mat file
output_mat_file = '/Users/neuro-240/Documents/BIL_and_GIN_Visit/streamline_count_matrices/connectivity_matrices_of_interest/streamline_count_matrices.mat';

% Initialize structure to store matrices
data = struct;

% Get a list of all npy files in the directory
npy_files = dir(fullfile(npy_dir, '*.npy'));

% Loop through each npy file
for i = 1:numel(npy_files)
    % Load the npy file
    npy_file = npy_files(i).name;
    npy_data = readNPY(fullfile(npy_dir, npy_file));
    
    % Extract subject ID from file name
    [~, file_name, ~] = fileparts(npy_file);
    subject_id = strtok(file_name, '_');
    
    % Store the matrix in the structure
    data.(subject_id) = npy_data;
end

% Save the structure to .mat file
save(output_mat_file, 'data');

%% Load binary mask
binary_mask = readNPY(fullfile(npy_dir, 'out_mask.npy'));

% Read node names from the text file
node_file = '/Users/neuro-240/Documents/BIL_and_GIN_Visit/AICHA/AICHA_ROI_MNI_V1.txt';
node_names = importdata(node_file);

node_names = node_names.textdata(:,1);

% Convert non-string elements of node_names to strings
node_names = node_names'

% Create a table with the double array and assign column and row names
T = array2table(binary_mask, 'VariableNames', node_names, 'RowNames', node_names);


%% Attempting to do a loop
% Create a table with the double array and assign column and row names
T = array2table(binary_mask, 'VariableNames', node_names, 'RowNames', node_names);
% Identify nodes with value 1 in the binary mask
valid_nodes = any(T{:,:}, 2); % This gives a logical vector indicating rows with at least one non-zero value

% Create a new table with filtered data
T_filtered = T(valid_nodes, valid_nodes);

% Find out which nodes were removed
removed_nodes = node_names(~valid_nodes);


% If you want to reset the row and column names of the filtered table to match the original T
T_filtered.Properties.RowNames = row_names(valid_nodes);
T_filtered.Properties.VariableNames = col_names(valid_nodes);


connectivity_matrix_filtered = connectivity_matrix(valid_nodes, valid_nodes);

% Get the field names of the structure
subject_ids = fieldnames(data);
% Create a new structure to store filtered data
filtered_data = struct();

% Loop through each subject ID
for subj_index = 1:numel(subject_ids)
    subjID = subject_ids{subj_index};

    current_connectivity_matrix = data.(subjID);
    
    % Filter out rows and columns corresponding to nodes with value 1 in the binary mask
    current_connectivity_matrix_filtered = current_connectivity_matrix(valid_nodes, valid_nodes);
    
    
    % Store the filtered matrix in the new structure with the same field name
    filtered_data.(subjID) = current_connectivity_matrix_filtered;
end

% Save the new structure containing filtered data
filtered_filename = '/Users/neuro-240/Documents/BIL_and_GIN_Visit/streamline_count_matrices/connectivity_matrices_of_interest/filtered_only/filtered_data.mat';
save(filtered_filename, 'filtered_data');
