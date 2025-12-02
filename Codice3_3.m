clc
clear 

%PASSARE I FARMACI IN QUESTO ORDINE QUANDO ESTRAGGO PARAMETRI PER ALL:
%BASAL, DEFACTINIB, IBRUTINIB, CYTOCALASINA-D
check_par = false;
while ~check_par 
    fprintf('Select the .mat files with the parameters obtained from the medians \n')
    [filename_par,folderpath_par] = uigetfile('*.mat');
    if isequal(filename_par, 0)
        fprintf('The user selected all the coeff \n');
        check_par = true;
    else
        filepath_par = fullfile(folderpath_par, filename_par);
        load(filepath_par)
    end
end

check = false;
i = 1;
fprintf('Select the cells with all the data \n')
while ~check    
    [filename, folderpath] = uigetfile('*.mat');
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        load(filepath)
    
        flip_Gprime(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:)); %G'
        flip_Gsecond(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:)); %G"
    
        [G_prime(:,:), median_prime(i,:), CI_prime(i,:,:)] = GetStatistics(flip_Gprime,i,true);
        [G_second(:,:), median_second(i,:), CI_second(i,:,:)] = GetStatistics(flip_Gsecond,i,true);
    end
    clear flip_Gprime, clear G_prime,
    clear flip_Gsecond, clear G_second,
    i = i +1;
end
frequencies_number = ExtractFreq(data_organized);

f1 = @(x,a,b) a*x.^b;
f2 = @(x,c,d,e,f) c*x.^d + e*x.^f;

pFig1 = figure;
for j = 1:size(median_prime,1)
    c1 = uisetcolor;
    plot(f1(1:1:max(frequencies_number),coeff_power1(j,1),coeff_power1(j,2)),'Color',c1,'HandleVisibility','off')
    hold on
    errorbar(frequencies_number,median_prime(j,:),CI_prime(j,:,1),CI_prime(j,:,2),...
        [],[],'o','Color',c1,'MarkerFaceColor',c1)
end
xlabel('Frequencies [Hz]')
ylabel("G' [Pa]")
condition_lin = strfind(filepath, 'lin');
condition_log = strfind(filepath, 'log');
if ~isempty(condition_lin)
    xticks([1,39.3,77.7,116.1,154.5,192.9,231.3,269.6,308,346.4,384.8,423.2,461.9,500])
    xticklabels({'1','39.3','77.7','116.1','154.5','192.9','231.3','269.6','308','346.4','384.4',...
        '423.2','461.9','500'})
elseif ~isempty(condition_log)
    xticks([1, 1.6, 2.5, 4, 6.5, 10, 16, 25, 40, ...
        65, 100, 160, 250, 400])
    xticklabels({'1', '1.6', '2.5', '4', '6.5', '10', '16', '25', '40', '65',...
        '100', '160', '250', '400'})
end

pFig2 = figure;
for j = 1:size(median_prime,1)
    c1 = uisetcolor;
    plot(f2(1:1:max(frequencies_number),coeff_power2(j,1),coeff_power2(j,2),...
        coeff_power2(j,3),coeff_power2(j,4)),'--','Color',c1,'HandleVisibility','off')
    hold on
    errorbar(frequencies_number,median_second(j,:),CI_second(j,:,1),CI_second(j,:,2),...
        [],[],'o','Color',c1,'MarkerFaceColor',c1)
end
xlabel('Frequencies [Hz]')
ylabel('G" [Pa]')
if ~isempty(condition_lin)
    xticks([1,39.3,77.7,116.1,154.5,192.9,231.3,269.6,308,346.4,384.8,423.2,461.9,500])
    xticklabels({'1','39.3','77.7','116.1','154.5','192.9','231.3','269.6','308','346.4','384.4',...
        '423.2','461.9','500'})
elseif ~isempty(condition_log)
    xticks([1, 1.6, 2.5, 4, 6.5, 10, 16, 25, 40, ...
        65, 100, 160, 250, 400])
    xticklabels({'1', '1.6', '2.5', '4', '6.5', '10', '16', '25', '40', '65',...
        '100', '160', '250', '400'})
end

