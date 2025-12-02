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

        [YM_temp(:,:), median_YM(i,:), CI_YM] = GetStatistics(flip_YM,i,true);

        color_temp = uisetcolor;

        YM_all{i} = YM_temp;
        colors{i} = color_temp(:)';

        dataset_ID{1,i} = ExtractNameAmplitude(filename);

    end
    clear flip_YM, clear YM_temp
    i = i+1;
end

choice_1 = listdlg('ListString',["Medians", "Data", "Correct Analysis (points)", "Correct Analysis (boxchart)"],...
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

elseif choice_1 == 3

    fprintf(['The analyisis is between each cell YM (tracked) and YM at 1st freq' ...
        'and the median will be displayed of the raios \n'])
    for ii = 1:num_dataset
        temp_YM = YM_all{1,ii};
        for jj = 1:size(temp_YM,1)
            temp_ratio(jj,:) = temp_YM(jj,:)/temp_YM(jj,1);
        end
    ratio_data{1,ii} = temp_ratio;
    ratio_medians(ii,:) = nanmedian(temp_ratio(:,:));
    clear temp_YM, clear temp_ratio
    end

    for ii = 1:num_dataset
        plot(frequencies_number,ratio_medians(ii,:),'-o','Color',colors{ii},'MarkerFaceColor',colors{ii})
        hold on
    end
    plot(1:1:max(frequencies_number),ones(1,numel(1:1:max(frequencies_number))),'--','Color',[0 0 0], 'HandleVisibility','off')
    xlabel('Frequency');
    ylabel('Median of the ratios YM_{i}^{(freq)}/YM_{1}^{(freq)}');
    legend(dataset_ID, 'Location', 'bestoutside');

elseif choice_1 == 4

    fprintf(['The analyisis is between each cell YM (tracked) and YM at 1st freq' ...
        'and it will be displayed the distribution \n'])
    figure; hold on; box on;
    widthTotal = 0.75;           % total width reserved for grouped boxes at each x tick
    boxWidthPerSet = widthTotal / num_dataset;

    if exist('frequencies_number','var') && ~isempty(frequencies_number) && isnumeric(frequencies_number) && numel(frequencies_number)>1
        freqLabels = frequencies_number;
        nFreq = numel(freqLabels);
    else
        % fallback: take number of columns from first dataset
        nFreq = size(YM_all{1},2);
        freqLabels = 1:nFreq;
    end

    h = gobjects(num_dataset,1);   

    for ii = 1:num_dataset
        temp_YM = YM_all{1,ii};
        for jj = 1:size(temp_YM,1)
            temp_ratio(jj,:) = temp_YM(jj,:)/temp_YM(jj,1);
        end
    ratio_data{1,ii} = temp_ratio;
    nObs = size(temp_ratio,1);
    xbase = repmat(1:nFreq, nObs, 1);    % nObs x nFreq
    xvec = xbase(:);
    yvec = temp_ratio(:);

    % remove NaNs (boxchart can't handle NaN entries)
    ok = ~isnan(yvec);
    xvec = xvec(ok);
    yvec = yvec(ok);

    offset = (ii - (num_dataset+1)/2) * boxWidthPerSet;

    h(ii) = boxchart(xvec + offset, yvec, 'BoxWidth', boxWidthPerSet*0.95);
    % set face color from your colors cell (assumes [r g b])
    try
        h(ii).BoxFaceColor = colors{ii};   % modern MATLAB property
        h(ii).MarkerColor = colors{ii};
        h(ii).MarkerStyle = 'none';
    catch
        % older MATLAB: try setting FaceColor if available
        try, set(h(ii),'FaceColor',colors{ii}); end
    end

    jitterAmount = boxWidthPerSet * 0.2;
    xJitter = (rand(size(xvec)) - 0.5) * 2 * jitterAmount;
    scatter(xvec + offset + xJitter, yvec, 15, colors{ii}, 'filled', ...
            'MarkerFaceAlpha', 0.3, 'MarkerEdgeColor', 'none','HandleVisibility','off');
    clear temp_YM, clear temp_ratio;
    end
    set(gca, 'XTick', 1:nFreq, 'XTickLabel', arrayfun(@num2str, freqLabels, 'UniformOutput', false));
    xlabel('Frequency');
    ylabel('Ratios (YM)_{i}^{(freq)}/(YM)_{1}^{(freq)}');
    legend(dataset_ID, 'Location', 'bestoutside');

end