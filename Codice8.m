clc
clear

i = 1;
check = false;


while ~check
    
    fprintf('Select YM file \n')
    [filename, folderpath] = uigetfile;
    if isequal(filename, 0)

        fprintf('The user selected all the YM data \n');
        check = true;

    else
        filepath = fullfile(folderpath, filename);
        load(filepath)

        %% Extracting Amplitude value and daata
        separated_filepath = strsplit(filepath,'\');
        separated_filepath = string(separated_filepath);
        [indx] = listdlg('ListString',separated_filepath);
        temp_string = separated_filepath(1,indx);
        temp_string = regexp(temp_string,'\d*', 'Match');
        amplitude(1,i) = str2double(temp_string);

        clear temp_string;

        % YM_all => each column is a different amplitude
        YM_all(i,1) = median_YM(1,1);
    end

    fprintf('Select the CI file \n')
    [filename2, folderpath2] = uigetfile;

    if isequal(filename2, 0)

        fprintf('The user selected all the CI data \n');
        check = true;

    else
        filepath2 = fullfile(folderpath2, filename2);
        load(filepath2)
        CI_all(i,1,:) = CI(1,1,:);  %CI(i,j,1) has lower limit, CI(i,j,2) has the upper limit

    end


    i = i+1;
end


%%Plotting
y = YM_all;
lower_error = y - CI_all(:,1,1);
upper_error = CI_all(:,1,2) - y;
figure;
errorbar(amplitude, y, lower_error, upper_error, 'o-');
