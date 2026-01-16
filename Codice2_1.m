clc
clear


i = 1;
check = false;
YM_all = {};
colors = {};
dataset_ID = {};

fprintf('Select the cells with all the data \n')
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

        [YM_temp(:,:), median_YM(i,:), CI_YM(i,:,:)] = GetStatistics(flip_YM,i,true);

        color_temp = uisetcolor;

        YM_all{i} = YM_temp;     
        colors{i} = color_temp(:)';

        dataset_ID{1,i} = ExtractNameAmplitude(filename);

    end
    clear flip_YM, clear YM_temp
    i = i+1;
end

nDatasets = numel(YM_all);

% determine frequency labels and count
if exist('frequencies_number','var') && ~isempty(frequencies_number) && isnumeric(frequencies_number) && numel(frequencies_number)>1
    freqLabels = frequencies_number;
    nFreq = numel(freqLabels);
else
    % fallback: take number of columns from first dataset
    nFreq = size(YM_all{1},2);
    freqLabels = 1:nFreq;
end

figure; hold on; box on;
widthTotal = 0.75;                    % total width reserved for grouped boxes at each x tick
boxWidthPerSet = widthTotal / nDatasets;

h = gobjects(nDatasets,1);           % store handles for legend

for i = 1:nDatasets
    Y = YM_all{i};                   % should be nObs x nFreq
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
            'MarkerFaceAlpha', 0.3, 'MarkerEdgeColor', 'black');
end

% tidy up axes & legend
set(gca, 'XTick', 1:nFreq, 'XTickLabel', arrayfun(@num2str, freqLabels, 'UniformOutput', false));
xlabel('Frequency [Hz]');
ylabel('YM [Pa]');
legend(h, dataset_ID, 'Location', 'bestoutside');
title('Grouped boxchart of all datasets by frequency');
hold off;