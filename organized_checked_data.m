function [data_new] = organized_checked_data(filepath,data_old)

temp_new_data = importdata(filepath);
size_new_data = size(temp_new_data.textdata);
size_old_data = size(data_old);

%Checking for different set of frequencies (not adapt for log-lin sets, but
%checks for discarded frequencies in the specific sample)
if size_old_data(1,1) ~= size_new_data(1,1)
   
    %Getting the curves name to get the frequencies
    temp_name_old_data = (string(data_old(2:1:size_old_data(1,1)))).';
    for i=1:size_new_data(1,1)
        temp_name_new_data{i,1} = temp_new_data.textdata{i,1};
    end
    temp_name_new_data = string(temp_name_new_data(:,1));

    %Deleting the 'Filename' row
    index_filename = cell2mat(strfind(temp_name_new_data,'Filename'));
    if ~isempty(index_filename)
        temp_name_new_data(index_filename,:) = [];
    end

    %Getting the frequencies (first as string then as number)
    %This procedure could be halved because we always pass firstly the file
    %with all frequencies, one can upgrade from it to change it
    old_frequencies = regexp(temp_name_old_data(:,1), '\d*.\d*Hz', 'Match');
    old_frequencies = regexp(string(old_frequencies(:,1)), '\d*.\d', 'Match');
    old_frequencies = str2double(string(old_frequencies));
    new_frequencies = regexp(temp_name_new_data(:,1), '\d*.\d*Hz', 'Match');
    new_frequencies = regexp(string(new_frequencies(:,1)), '\d*.\d', 'Match');
    new_frequencies = str2double(string(new_frequencies));
    
    all_freq = union(new_frequencies,old_frequencies);

    clear temp_name_new_data, clear temp_name_old_data
    
    %Initialazing data_new
    data_new = cell(size(data_old));

    %Getting names and parameters
    data_new(:,1) = data_old(:,1);
    data_new(1,2:size(data_new,2)) = data_old(1,2:size(data_old,2));
    
    %Getting 
    size_data_sync = [size(data_old,1)-1, size(data_old,2)-1];
    new_data_sync = nan(size_data_sync);
    [~, loc_new_data] = ismember(new_frequencies, all_freq);
    prova = temp_new_data.data;
    new_data_sync(loc_new_data,:) = temp_new_data.data;
    new_data_sync = mat2cell(new_data_sync,ones(1, size(new_data_sync,1)), ones(1, size(new_data_sync,2)));

    data_new(2:size(data_new,1),2:size(data_new,2)) = new_data_sync(:,:);

else 
    data_new = organize_data(filepath);    
end

end