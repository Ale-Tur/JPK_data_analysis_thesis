clc 
clear

%Code to get the YM of all the cell at the first frequency

i = 1;
check = false;
while ~check

    %Getting the filepath through user file selection
    [filename, folderpath] = uigetfile('*.mat');

    if isequal(filename, 0)
        fprintf('User finshed file selection. \n');
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        load(filepath)
        %To save the data with the right name
        fprintf('Select a possible name in the filepath: \n')
        separated_filepath = strsplit(filepath,'\');
        [indx] = listdlg('ListString',separated_filepath);

        fprintf('Select multiple possible suffix to add to the data name \n')
        temp_string = string(separated_filepath{1,indx});
        temp2_string = temp_string;
        separated2_filepath = strsplit(temp_string,'_');
        [indx] = listdlg('ListString',separated2_filepath);
        name_data = separated2_filepath(1,indx(1));
        for j=2:numel(indx)
            name_data = name_data + "_" +separated2_filepath(1,indx(j));
        end
        fprintf('You have selected: '+ name_data + '\n')

        YM_first_f{i,1} = data_organized(2,8,:);
        YM_first_f{i,2} = name_data;
    end
i = i+1;

end

separated3_filepath = strsplit(temp2_string,'_');
[indx] = listdlg('ListString',separated3_filepath);
name_file = separated3_filepath(1,indx(1));
for j=2:numel(indx)
    name_file = name_file + "_" +separated3_filepath(1,indx(j));
end
save(name_file, 'YM_first_f')