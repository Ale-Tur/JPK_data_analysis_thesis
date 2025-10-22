clc 
clear 

i = 1;
check = false;
YM_all = {};
colors = {};
dataset_ID = {};


while ~check
   
    [filename, folderpath] = uigetfile;
    if isequal(filename,0)
        
        fprintf('The user selcted all the data \n')
        check = true;

    else
        filepath = fullfile(folderpath,filename);
        load(filepath)

        dim_DO_1 = size(data_organized,1);
        frequencies_number = ExtractFreq(data_organized);
        flip_YM(:,:) = cell2mat(data_organized(2:dim_DO_1,8,:));

        [YM_temp(:,:), median_YM(i,:), CI_YM] = GetStatistics(flip_YM,i);

        color_temp = uisetcolor;

        YM_all{i} = YM_temp;
        colors{i} = color_temp(:)';

        dataset_ID{1,i} = ExtractNameAmplitude(filename);

    end
    clear flip_YM, clear YM_temp
    i = i+1;
end

choice_1 = listdlg('ListString',["Medians", "Data"],...
        'PromptString', 'Analysis on ratio between medians or first median and data?',...
        'ListSize',[200,300]);
ratio_medians = zeros(size(median_YM));
ratio_data = cell(size(YM_all));
num_dataset = numel(YM_all);
if choice_1 == 1
    
    fprintf('The ratio will be calculated as (Median_i)/(Median_1) \n')
    for ii = 1:num_dataset
        ratio_medians(ii,:) = median_YM(ii,:)/median_YM(ii,1);
    end

    for ii = 1:num_dataset
        plot(frequencies_number,ratio_medians(ii,:),'-o','Color',colors{ii},'MarkerFaceColor',colors{ii})
        hold on
    end
    plot(1:1:max(frequencies_number),ones(1,numel(1:1:max(frequencies_number))),'--','Color',[0 0 0])
    xlabel('Frequency');
    ylabel('Ratio M_{i}/M_{1}');
    legend(dataset_ID, 'Location', 'bestoutside');
    
elseif choice_1 == 2

    fprintf(['The ratio will be calculated between all the data in a freq.' ...
        'and Median_1, the plot will be the median of the ratios \n'])
    ratio_medians(:,1) = 1;
    for ii = 1:num_dataset
        temp_YM = YM_all{1,ii};
        ratio_data{1,ii} = temp_YM(:,2:size(temp_YM,2))/median_YM(ii,1);
        temp_ratio = ratio_data{1,ii};
        ratio_medians(ii,2:size(ratio_medians,2)) = nanmedian(temp_ratio(:,:));
        clear temp_YM, clear temp_ratio
    end

    for ii = 1:num_dataset
        plot(frequencies_number,ratio_medians(ii,:),'-o','Color',colors{ii},'MarkerFaceColor',colors{ii})
        hold on
    end
    plot(1:1:max(frequencies_number),ones(1,numel(1:1:max(frequencies_number))),'--','Color',[0 0 0])
    xlabel('Frequency');
    ylabel('Median of the ratio YM_{i}^{(freq)}/M_{1}');
    legend(dataset_ID, 'Location', 'bestoutside');
    
end