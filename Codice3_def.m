clc 
clear

%% Load data

check = false;
i = 1;
experiments = {'amplitude','drugs'};
[indx] = listdlg('ListString',experiments,'PromptString',...
    'Choose the type of data to analyze');
fprintf('Select the cells with all the data \n')
while ~check    
    [filename, folderpath] = uigetfile('*.mat');
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;
    else
        fprintf('%s\n', filename);
        filepath = fullfile(folderpath, filename);
        load(filepath)
        list_names(i) = string(ExtractName(filepath,string(experiments{1,indx}))); 
    
        flip_Gprime(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:)); %G'
        flip_Gsecond(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:)); %G"
        flip_Loss(:,:) = cell2mat(data_organized(2:size(data_organized,1),25,:)); %Loss
    
        [G_prime(:,:), median_prime(i,:), CI_prime(i,:,:)] = GetStatistics(flip_Gprime,i,true);
        [G_second(:,:), median_second(i,:), CI_second(i,:,:)] = GetStatistics(flip_Gsecond,i,true);
        [Loss_temp(:,:), median_Loss(i,:), CI_loss(i,:,:)] = GetStatistics(flip_Loss,i,true);
    end
    clear flip_Gprime, clear G_prime,
    clear flip_Gsecond, clear G_second,
    clear flip_Loss, clear Loss_temp,
    i = i +1;
end
dataset_size = size(median_Loss,1);

[indx] = listdlg('ListString',{'Load Colors','Choose colors'},'PromptString',...
    'Choose the colors for the data');
if indx == 1
    [filename_color,folderpath_color] = uigetfile('*.mat');
    filepath_color = fullfile(folderpath_color, filename_color);
    load(filepath_color)
elseif indx == 2
    for ii =1:dataset_size
        colors{ii} = uisetcolor();
    end
end

%% Plotting and Analysing 

[indx] = listdlg('ListString',{'Single','All','Vs'},'PromptString',...
    'Choose the plotting method');

f1 = @(x,a,b) a*x.^b;
f2 = @(x,c,d,e,f) c*x.^d + e*x.^f;
frequencies_number = ExtractFreq(data_organized);
condition_lin = strfind(filepath, 'lin');
condition_log = strfind(filepath, 'log');
if indx == 1 % SIGNLE DATASET PLOTTING AND ANALYSING (FITTED ALREDY)
    check_par = false;
    fprintf('Select the .mat files with the parameters obtained from the medians \n')
    while ~check_par 
        [filename_par,folderpath_par] = uigetfile('*.mat');
        if isequal(filename_par, 0)
            fprintf('The user selected all the coeff \n');
            check_par = true;
        else
            fprintf('%s\n',filename_par)
            filepath_par = fullfile(folderpath_par, filename_par);
            load(filepath_par)
        end
    end
    [indx_data] = listdlg('ListString',list_names,'PromptString',...
    'Choose the data to plot');
    pFig1 = figure;
    ax1 = axes;
    plot(f1(1:1:max(frequencies_number),coeff_power1(indx_data,1),coeff_power1(indx_data,2)),...
        'Color',colors{indx_data},'HandleVisibility','off')
    hold on
    errorbar(frequencies_number,median_prime(indx_data,:),CI_prime(indx_data,:,1),CI_prime(indx_data,:,2),...
        [],[],'o','Color',colors{indx_data},'MarkerFaceColor',colors{indx_data})
    hold on
        plot(f2(1:1:max(frequencies_number),...
            coeff_power2(indx_data,1),coeff_power2(indx_data,2),coeff_power2(indx_data,3),...
            coeff_power2(indx_data,4)),'--','Color',colors{indx_data},'HandleVisibility','off')
    hold on
    errorbar(frequencies_number,median_second(indx_data,:),CI_second(indx_data,:,1),...
        CI_second(indx_data,:,2),[],[],'o','Color',colors{indx_data},'Marker','o')
    xlabel('Frequencies [Hz]')
    ylabel("G* [Pa]")
    xticks(frequencies_number)
    xticklabels(string(frequencies_number))
    set(gca, 'YScale', 'log')
    if ~isempty(condition_log)
        ax1.XScale = 'log';
        ax2 = axes('Position',[0.548958333333333,0.183537263626251,0.15,0.32]);
        errorbar(frequencies_number,median_Loss(indx_data,:),CI_loss(indx_data,:,1),CI_loss(indx_data,:,2),[],[],...
            'o','Color',colors{indx_data},'MarkerFaceColor',colors{indx_data},'Marker','*');
        hold on
        plot(1:1:max(frequencies_number),ones(1,numel(1:1:max(frequencies_number))),'--','Color',[0 0 0], 'HandleVisibility','off')
        ax2.XScale = 'log';
        ax2.YScale = 'log';
        ax2.XTick = [1,100,500];
        ax2.XTickLabels = (string([1,100,500]));
        ax2.XLim = [1,500];
    elseif ~isempty(condition_lin)
        ax2 = axes('Position',[0.548958333333333,0.183537263626251,0.15,0.32]);
        errorbar(frequencies_number,median_Loss(indx_data,:),CI_loss(indx_data,:,1),CI_loss(indx_data,:,2),[],[],...
            'o','Color',colors{indx_data},'MarkerFaceColor',colors{indx_data},'Marker','*');
        hold on
        plot(1:1:max(frequencies_number),ones(1,numel(1:1:max(frequencies_number))),'--','Color',[0 0 0], 'HandleVisibility','off')
        ax2.YScale = 'log';
        ax2.XTick = [1,250,500];
        ax2.XTickLabels = (string([1,250,500]));
        ax2.XLim = [1,500];
    end
    ax1.XGrid = 'on';
    ax1.YGrid = 'on';
    ax1.PlotBoxAspectRatio = [1,1,1];
    ax2.XGrid = 'on';
    ax2.YGrid = 'on';
    ax2.PlotBoxAspectRatio = [1,1,1];
    
elseif indx == 2 % ALL DATASET PLOTTING (BOTH FITTED ALREADY OR TO FIT)

end