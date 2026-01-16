clc
clear

experiments = {'amplitude','drugs'};
[indx_exp] = listdlg('ListString',experiments,'PromptString',...
    'Choose the type of data to analyze');

check = false;
i_WT = 1;
i_KO1 = 1;

while ~check

    [filename,folderpath] = uigetfile('*.mat');
     
    if isequal(filename,0)

        fprintf('The user selected all the data \n');
        check = true;

    else
        
        filepath = fullfile(folderpath,filename);
        load(filepath);
        fprintf('%s \n',filename);
        frequencies_number = ExtractFreq(data_organized);

        WT_condition = strfind(filepath,'MECWT');
        KO1_condition = strfind(filepath,'MECKO1');
        if ~isempty(WT_condition)

            flip_YM(:,:) = cell2mat(data_organized(2:size(data_organized,1),8,:));
            [YM_temp(:,:), median_YM_WT(i_WT,:), CI_YM_WT(i_WT,:,:)] = GetStatistics(flip_YM,i_WT,true);        
            YM_all_WT{i_WT} = YM_temp;            
            dataset_ID_WT{1,i_WT} = string(ExtractName(filepath,string(experiments{1,indx_exp})));

            clear flip_YM, clear YM_temp
            i_WT = i_WT+1;
        elseif ~isempty(KO1_condition)
            flip_YM(:,:) = cell2mat(data_organized(2:size(data_organized,1),8,:));
            [YM_temp(:,:), median_YM_KO1(i_KO1,:), CI_YM_KO1(i_KO1,:,:)] = GetStatistics(flip_YM,i_KO1,true);        
            YM_all_KO1{i_KO1} = YM_temp;            
            dataset_ID_KO1{1,i_KO1} = string(ExtractName(filepath,string(experiments{1,indx_exp})));

            clear flip_YM, clear YM_temp
            i_KO1 = i_KO1+1;
        end
        clear WT_condition; clear KO1_condition;
    end

end

%choose frequencies to study
indx_freq = listdlg('ListString',string(frequencies_number),'PromptString',...
    'Choose the frequencies to plot');
nFreq = numel(indx_freq);
nDataset_KO1 = numel(YM_all_KO1);

data25nm_WT = YM_all_WT{1}(:, 1);
data25nm_WT = data25nm_WT(~isnan(data25nm_WT(:,1)));
for i = 1:nDataset_KO1
    data_temp = YM_all_KO1{i};
    for ii = 1:nFreq
        KO_comparison = data_temp(:, ii);
        KO_comparison = KO_comparison(~isnan(KO_comparison));
        p_value_WTvsKO1(ii, i) = ranksum(data25nm_WT, KO_comparison);
    end
end