clc
clear

i = 1;
check = false;

while ~check

    [filename, folderpath] = uigetfile;
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
        %% Getting statistics

        %Getting the right Parameters, in this case Loss'
        flip_Loss(:,:) = cell2mat(data_organized(2:size(data_organized,1),25,:));
        for ii = 1:size(flip_Loss,1)
            for jj = 1:size(flip_Loss,2)
                if flip_Loss(ii,jj) < 0
                    flip_Loss(ii,jj) = NaN;
                end
            end
        end
        
        %This command is needed to easily obtain Loss
        Loss_Factor = flip_Loss.';

        %Getting the median for loss (separeted for future errors check
        %maybe?)
        for j = 1:size(Loss_Factor,2)
            median_Loss(i,j) = nanmedian(Loss_Factor(:,j));
            %fprintf('%d \n', j)
        end  
        
        %Getting the confidence interval for G' 
        for j = 1:size(Loss_Factor,2)
            n_NaN_loss = numnan(Loss_Factor(:,j));
            standard_error_loss = nanstd(Loss_Factor(:,j))/sqrt(size(Loss_Factor,2)-n_NaN_loss);
            t_score_loss = tinv([0.025 0.975], size(Loss_Factor,2)-1-n_NaN_loss);
            CI_loss(i,j,:) = nanmean(Loss_Factor(:,j)) + t_score_loss*standard_error_loss; %CI(i,j,1) has lower limit, CI(i,j,2) has the upper limit
        end

        %% Plotting Loss Factor
        c = uisetcolor;

       %Plotting the medians and the CI
        f1 = errorbar(frequencies_number(:,1),median_Loss(i,:),CI_loss(i,:,1),CI_loss(i,:,2),[],[],...
            'o','Color',c,'MarkerFaceColor',c);
        xlabel('Frequencies [Hz]')
        ylabel('Loss Factor')
        hold on



    end
    clear flip_Loss;
end

plot(1:1:max(frequencies_number),ones(1,numel(1:1:max(frequencies_number))),'--','Color',[0 0 0], 'HandleVisibility','off')