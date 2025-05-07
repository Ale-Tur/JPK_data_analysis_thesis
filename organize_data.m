function [data] = organize_data(filepath)

temp_data = importdata(filepath);
size_data = size(temp_data.textdata);

%ORGANIZING .tsv DATA TO OBTAIN A CLEAN DATA STRUCTURE

%Getting curves name
temp_names = cell(size_data(1,1),1);
for i = 1:size_data(1,1)
    temp_names{i,1} = temp_data.textdata{i,1};
end

%Getting parameters name
temp_data.textdata(:,1) = [];
while size(temp_data.textdata,1) > 1
    temp_data.textdata(2,:) = [];
end

%Creating organized data
data = cell(size_data);

data(:,1) = temp_names(:,1);
data(1,2:size_data(1,2)) = temp_data.textdata(1,:);
for i = 2:size_data(1,1)
    for j = 2:size_data(1,2)
        data{i,j} = temp_data.data(i-1,j-1);
    end
end
clear temp_names; clear temp_data; 