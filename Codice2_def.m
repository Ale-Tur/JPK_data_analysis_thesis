clc
clear

experiments = {'amplitude','drugs'};
[indx_exp] = listdlg('ListString',experiments,'PromptString',...
    'Choose the type of data to analyze');

i = 1;
check = false;
YM_all = {};
colors = {};
dataset_ID = {};

while ~check
    
    [filename, folderpath] = uigetfile;
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;

    else
        filepath = fullfile(folderpath, filename);
        load(filepath)
        fprintf("%s \n",filename)

        %Extract Freq.
        frequencies_number = ExtractFreq(data_organized);

        flip_YM(:,:) = cell2mat(data_organized(2:size(data_organized,1),8,:));

        [YM_temp(:,:), median_YM(i,:), CI_YM(i,:,:)] = GetStatistics(flip_YM,i,true);

        YM_all{i} = YM_temp;     

        dataset_ID{1,i} = string(ExtractName(filepath,string(experiments{1,indx_exp})));

    end
    clear flip_YM, clear YM_temp
    i = i+1;
end

nDatasets = numel(YM_all);

[indx_col] = listdlg('ListString',{'Load Colors','Choose colors'},'PromptString',...
    'Choose the colors for the data');
if indx_col == 1
    [filename_color,folderpath_color] = uigetfile('*.mat');
    filepath_color = fullfile(folderpath_color, filename_color);
    load(filepath_color)
elseif indx_col == 2
    for ii =1:nDatasets
        colors{ii} = uisetcolor();
    end
end

% determine frequency labels and count
if exist('frequencies_number','var') && ~isempty(frequencies_number) && isnumeric(frequencies_number) && numel(frequencies_number)>1
    freqLabels = frequencies_number;
else
    % fallback: take number of columns from first dataset
    nFreq = size(YM_all{1},2);
    freqLabels = 1:nFreq;
end

%chose frequencies to plot
indx_freq = listdlg('ListString',string(frequencies_number),'PromptString',...
    'Choose the frequencies to plot');
nFreq = numel(indx_freq);

figure; hold on; box on;
widthTotal = 0.75;                    % total width reserved for grouped boxes at each x tick
boxWidthPerSet = widthTotal / nDatasets;

h = gobjects(nDatasets,1);           % store handles for legend

for i = 1:nDatasets
    Y_temp = YM_all{i};                   % should be nObs x nFreq
    nObs = size(Y_temp,1);
    Y = NaN(nObs, nFreq);
    for ii = 1:size(indx_freq,2)
        Y(:,ii) = Y_temp(:,indx_freq(ii));
    end
    Y_all{i} = Y;
    if isempty(Y), continue; end

    % vectorize: x index for each value (1..nFreq) and y values
    nObs = size(Y,1);
    xbase = repmat(1:nFreq, nObs, 1);    % nObs x nFreq
    xvec = xbase(:);
    yvec = Y(:);

    % remove NaNs (boxchart can't handle NaN entries)
    ok = ~isnan(yvec);
    xvec = xvec(ok);
    yvec = yvec(ok);

    % compute a horizontal offset so boxes for datasets don't overlap
    offset = (i - (nDatasets+1)/2) * boxWidthPerSet;

    % plot boxchart at shifted positions and without outlier
    h(i) = boxchart(xvec + offset, yvec, 'BoxWidth', boxWidthPerSet*0.95,'BoxMedianLineColor','red');
    try
        h(i).BoxFaceColor = colors{i};   % modern MATLAB property
        h(i).MarkerColor = colors{i};
        h(i).MarkerStyle = 'none';
    catch
        % older MATLAB: try setting FaceColor if available
        try, set(h(i),'FaceColor',colors{i}); end
    end

    jitterAmount = boxWidthPerSet * 0.2;
    xJitter = (rand(size(xvec)) - 0.5) * 2 * jitterAmount;
    scatter(xvec + offset + xJitter, yvec, 15, colors{i}, 'filled', ...
            'MarkerFaceAlpha', 0.3);
end

% tidy up axes & legend
set(gca, 'XTick', 1:nFreq, 'XTickLabel', arrayfun(@num2str, freqLabels(indx_freq), 'UniformOutput', false));
xlabel('\bf{Frequency [Hz]}');
ylabel('\bf{YM [Pa]}');
legend(h, dataset_ID, 'Location', 'bestoutside');
title("Young's Modulus of all datasets, by frequency");

yl = ylim;   
for i = 1:nFreq-1
    xline(i + 0.5, '--', 'LineWidth', 1,'HandleVisibility','off');
end
ylim(yl);

% %MI SA SONO SBAGLIATI QUESTI CORREGGERE (13/01)
% Dataset25_FirstFreq = Y_all{1}(:,1);
% % Dataset25_FirstFreq = Dataset25_FirstFreq(~isnan(Dataset25_FirstFreq(:,1)));
% for i = 1:nDatasets
%     data_temp = Y_all{i};
%     for ii = 1:nFreq
%         if ~(i== 1 && ii == 1)
%             % data_ComparisonTest = data_temp(~isnan(data_temp(:,ii)));
%             data_ComparisonTest = data_temp(:,ii);
%             p_value_25(ii,i) = ranksum(Dataset25_FirstFreq,data_ComparisonTest);
%         end
%     end
% end
% 
% for i = 1:nDatasets
%     data_temp = Y_all{i};
%     data25_comparison = data_temp(:,1);
%     % data25_comparison = data25_comparison(~isnan(data25_comparison));
%     for ii = 2:nFreq
%         % data_ComparisonTest = data_temp(~isnan(data_temp(:,ii)));
%         data_ComparisonTest = data_temp(:,ii);
%         p_value(ii-1,i) = ranksum(data25_comparison,data_ComparisonTest) ;
%     end
% end

for i = 1:nFreq              
    for j = 2:nDatasets      
        p_value(i, j-1) = ranksum(YM_all{1,1}(:, i),YM_all{1,j}(:, i));
        p_value_noNaN(i,j-1) = ranksum(...
            YM_all{1,1}(~isnan(YM_all{1,1}(:,i)),i),...
            YM_all{1,j}(~isnan(YM_all{1,j}(:,i)),i));
    end
end

ax1 = gca;
ax1.YScale = "log";
ax1.XGrid = 'on';
ax1.YGrid = 'on';
ax1.PlotBoxAspectRatio = [1.5,1,1];
hold off;

% save("Output\p_value_FirstFreqToAll","p_value_25")
save("Output\p_value_FirstFreqEachDataset","p_value")