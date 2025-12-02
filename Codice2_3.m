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
        % xticks([1.1025, 1.764, 2.75625, 4.41, 7.16625, 11.025, 17.64, 27.5625, 44.1, ...
        %     71.6625, 110.25, 176.4, 275.625, 441])
        % xticklabels({'1', '1.6', '2.5', '4', '6.5', '10', '16', '25', '40', '65',...
        %     '100', '160', '250', '400'})

        f1 = errorbar(frequencies_number(:,1) + offset,median_YM(i,:),CI_YM(i,:,1),CI_YM(i,:,2),[],[],...
            'o','Color',c,'MarkerFaceColor',c);
        xticks([11,49.3,87.7,126.1,164.5,202.9,241.3,279.6,318,356.4,394.8,433.2,471.9,510])
        xticklabels({'1','39.3','77.7','116.1','154.5','192.9','231.3','269.6','308','346.4','384.4',...
            '423.2','461.9','500'})

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