clc 
clear 

%To plot all the data the user want
i=1;
check = false;
while ~check
    [filename,folderpath] = uigetfile;
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        load(filepath)
        
        
        %EXTRACTING FREQUENCIES
        %One can extract frequencies just from one dataset assuming that all the
        %data are taken at the same frequencies
        
        %Contains the name of the curves, to extract frequencies
        temp_name_vector = string(data_organized(:,1,1));
        
        %Searching for the 'Filename' legend in data, because how the first code is
        %done this is needed
        index_filename = cell2mat(strfind(temp_name_vector,'Filename'));
        
        %If there is the legend 'Filename', we eliminate it
        if ~isempty(index_filename)
            temp_name_vector(index_filename,:) = [];
        end
        
        obtained_frequencies = regexp(temp_name_vector(:,1), '\d*.\d*Hz', 'Match');
        
        frequencies_number = regexp(string(obtained_frequencies(:,1)), '\d*.\d', 'Match');
        frequencies_number = str2double(string(frequencies_number));
        
        
        %MAKING PLOT
        
        %Getting the right Parameters, in this case the YM
        flip_YM(:,:) = cell2mat(data_organized(2:size(data_organized,1),8,:));
        
        %This command is needed to easily obtain YM vs frequencies
        YM = flip_YM.';
        
        %Getting the median
        for j = 1:size(YM,2)
            median_YM(i,j) = nanmedian(YM(:,j));
        end
        
        %Getting the confidence interval
        for j = 1:size(YM,2)
            n_NaN = numnan(YM(:,j));
            standard_error = nanstd(YM(:,j))/sqrt(size(YM,2)-n_NaN);
            t_score = tinv([0.025 0.975], size(YM,2)-1-n_NaN);
            CI(i,j,:) = nanmean(YM(:,j)) + t_score*standard_error; %CI(i,j,1) has lower limit, CI(i,j,2) has the upper limit
        end

        %Searching for previous boxes
        prev_boxes = findobj(gca,'Tag','Box');

        %Plotting boxplot
        boxplot(YM,frequencies_number)
        xlabel('Frequencies (Hz)')
        ylabel('YM')
        hold on 

        %Getting plot title
        if i == 1
            separated_filepath = strsplit(filepath,'\');
            [indx] = listdlg('ListString',separated_filepath);
            temp_string = string(separated_filepath{1,indx});
            separated2_filepath = strsplit(temp_string,'_');
            [indx] = listdlg('ListString',separated2_filepath);
            if indx == 1
                temp_title = separated2_filepath(indx);
                title(temp_title)
            else
                temp_title = separated2_filepath(1,indx(1));
                for j=2:size(indx,2)
                    temp_title = temp_title + ' ' + separated2_filepath(1,indx(j));
                    title(temp_title)
                end
            end
        else
            temp_title = temp_title + ' vs';
            separated_filepath = strsplit(filepath,'\');
            [indx] = listdlg('ListString',separated_filepath);
            temp_string = string(separated_filepath{1,indx});
            separated2_filepath = strsplit(temp_string,'_');
            [indx] = listdlg('ListString',separated2_filepath);
            if indx == 1
                temp_title = temp_title + ' ' + separated2_filepath(indx);
                title(temp_title)
            else
                temp_title = temp_title + ' ' + separated2_filepath(1,indx(1));
                for j=2:size(indx,2)
                    temp_title = temp_title + ' ' + separated2_filepath(1,indx(j));
                    title(temp_title)
                end
            end            
        end
        clear separated_filepat, clear separated2_filepath
        clear temp_string
        
        
        %To get boxes filled with colors
        %CLOSE PREVIOUS PLOTS TO MAKE THIS COMMAND WORKS
        c = uisetcolor;
        new_boxes = setdiff(findobj(gca,'Tag','Box'),prev_boxes);
        for j = 1:length(new_boxes)
            patch(get(new_boxes(j),'XData'), get(new_boxes(j),'YData'), c, 'FaceAlpha', 0.3);
        end
        
        %Those lines are needed to have the jitter one the data for the scatter and
        %the data from the scatter "aligned" with the data from the boxplot
        numGroups = numel(frequencies_number);
        x_scatter = repmat(1:numGroups, size(YM,1), 1);
        x_scatter(:,:) = x_scatter(:,:) + 0.2*(rand(size(x_scatter)) - 0.5);
        
        scatter(x_scatter(:,:),YM(:,:),26,c,'filled',...
            'MarkerFaceAlpha',0.7)
        hold on
        % %Plotting line between each data of each sample
        % for i = 1:size(x_scatter,1)
        %     plot(x_scatter(i,:),YM(i,:),'Color',c)
        %     hold on
        % end
        clear YM; clear flip_YM
        i = i+1;
    end
end