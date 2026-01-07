clc 
clear

%This code is used to convert the data from a jpk analysis from a .tsv into a readble and more
%menageable MATLAB cell. This code NEED the functions organize_data and
%organize_check_data to work. This code NEED to ALWAYS PASS FIRST AN
%EXPERIMENT WERE ALL THE FREQUENCIES WERE TAKEN. For files with discarded
%frequencies the code insert a row with NaN. The code let the user choose all
%the wanted files and the name to give (through the filepath of the
%directory), one also has to choose if the frequency sweep is done through
%linear or log delta.


i = 1;
check = false;
while ~check

    %Getting the filepath through user file selection
    fprintf('you are choosing the %d ° file \n',i)
    [filename, folderpath] = uigetfile('*.tsv');
    fprintf('%s \n', filename);

    if isequal(filename, 0)

        fprintf('User cancelled file selection. \n');
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        if i == 1
            data_organized(:,:,i) = organize_data(filepath);
            i = i+1;
        else
            data_organized(:,:,i) = organized_checked_data(filepath,...
                data_organized(:,:,1));
            i = i+1;
        end
    end
end

%To give the right name to the data file
fprintf('Select a possible name in the filepath: \n')
separated_filepath = strsplit(filepath,'\');
[indx, check_list] = listdlg('ListString',separated_filepath);

fprintf('Select multiple possible suffix to add to the file name \n')
temp_string = string(separated_filepath{1,indx});
separated2_filepath = strsplit(temp_string,'_');
[indx, check_list] = listdlg('ListString',separated2_filepath);

%To get the right name
if size(indx,2) == 1
    temp_string = string(separated2_filepath(1,indx));
    data_name = 'data_' + temp_string + '.mat';
else
    data_name = 'data';
    for i=1:size(indx,2)
        temp_string = string(separated2_filepath(1,indx(1,i)));
        data_name = data_name + "_" + temp_string ;
    end
    fprintf('Is the frequencies sweep in log or linear steps? \n')
    log_lin = ["log", "lin", "reverse"];
    [indx, check_list]  =listdlg('ListString',log_lin);
    data_name = data_name + "_" +log_lin(1,indx) + '.mat';
end
clear temp_string;

save(data_name, 'data_organized')
