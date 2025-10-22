function [new_cell] = OrganizeCellParameters(all_coeff_cell)

num_indentation = size(all_coeff_cell,2);
num_parameters = size(all_coeff_cell{1},2);

new_cell = cell(1,num_indentation,num_parameters);

for i=1:num_indentation
    temp_matrix = all_coeff_cell{i};
    for j=1:num_parameters
        new_cell{1,i,j} = temp_matrix(:,j); 
    end
end

end