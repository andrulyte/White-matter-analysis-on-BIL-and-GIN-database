
% Load demographics file
demog = readtable("HFLI_good.csv");

% Define the classes and combinations
classes = {'Atypical', 'Strong-Atypical', 'Typical'};
combinations = {'Atypical', 'Strong-Atypical'; 'Atypical', 'Typical'; 'Strong-Atypical', 'Typical'};
classNames = {'Atypical_StrongAtypical', 'Atypical_Typical', 'StrongAtypical_Typical'};

for i = 1:size(combinations, 1)
    % Filter "filtered_demog" to include only the current combination
    filtered_demog_combination = filtered_demog(ismember(filtered_demog.AtypPROD3Classes, combinations(i, :)), :);

    % Create binary lists for the current combination
    binaryList1 = ismember(filtered_demog_combination.AtypPROD3Classes, combinations{i, 1});
    binaryList2 = ismember(filtered_demog_combination.AtypPROD3Classes, combinations{i, 2});

    % Create a design matrix with two columns for the current combination
    design_matrix = zeros(size(filtered_demog_combination, 1), 2);
    design_matrix(:, 1) = binaryList1; % For the first class in the combination
    design_matrix(:, 2) = binaryList2; % For the second class in the combination

    % Save design matrix file for the current combination
    dlmwrite(sprintf('design_matrix_%s.txt', classNames{i}), design_matrix, ' ');

    % Get the field names from your structure
    fieldsToKeep = fieldnames(filtered_data);



  % Filter the structure data to include only the current combination
    fieldsToKeep1 = filtered_demog.NSujet(binaryList1);
    fieldsToKeep2 = filtered_demog.NSujet(binaryList2);
    fieldsToKeep = intersect(fieldsToKeep, [fieldsToKeep1; fieldsToKeep2]);


     % Ensure only field names in fieldsToKeep are retained in filtered_data_combination
    fieldsToRemove = setdiff(fieldnames(filtered_data), fieldsToKeep);
    filtered_data_combination = rmfield(filtered_data, fieldsToRemove);


    % Save structure file for the current combination
    save(sprintf('filtered_data_%s.mat', classNames{i}), 'filtered_data_combination');
end