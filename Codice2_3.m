clc
clear


i = 1;
check = false;
scale_factor = 1.05;
offset = 0;

while ~check
    
    [filename, folderpath] = uigetfile;
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;

    else
        filepath = fullfile(folderpath, filename);
        load(filepath)

        %Extract Freq.
        frequencies_number = ExtractFreq(data_organized);

        flip_YM(:,:) = cell2mat(data_organized(2:size(data_organized,1),8,:));

        [YM_temp(:,:), median_YM(i,:), CI_YM] = GetStatistics(flip_YM,i,true);
        average_YM(i,1) = mean(median_YM(i,:));
        StDev_YM(i,1) = std(median_YM(i,:));

        c = uisetcolor;
        % f1 = errorbar(frequencies_number(:,1) * scale_factor^(i-1),median_YM(i,:),CI_YM(i,:,1),CI_YM(i,:,2),[],[],...
        %     'o','Color',c,'MarkerFaceColor',c);
        f1 = errorbar(frequencies_number(:,1) + offset,median_YM(i,:),CI_YM(i,:,1),CI_YM(i,:,2),[],[],...
            'o','Color',c,'MarkerFaceColor',c);
        % f1 = plot(frequencies_number(:,1) * scale_factor^(i-1),median_YM(i,:),'o','Color',c,'MarkerFaceColor',c);
        % f1 = plot(frequencies_number(:,1) + offset, median_YM(i,:),'o','Color',c,'MarkerFaceColor',c);
        xlabel('Frequencies [Hz]')
        ylabel('YM [Pa]')
        grid("on")
        hold on 
        colors(i,:) = c;
    end
    clear flip_YM, clear YM_temp
    i = i+1;
    offset = offset + 5;
end

pause()
hold off 
scatter([25,50,100,150,200,250], average_YM, [], colors, 'filled'); 
hold on
errorbar([25,50,100,150,200,250], average_YM, StDev_YM, 'k', 'LineStyle', 'none');