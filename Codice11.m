clc 
clear

%QUESTO CODICE è NEFASTO, BISOGNA METTERLO A POSTO, L'HO FATTO COSì PER
%TIRARE FUORI ALMENO UNA ANALISI
%SISTEMARE IL MODO IN CUI SCEGLI AMPIEZZA, ORA è A MANO E IL MODO IN CUI
%IMPOSTARE L'ISTOGRAMMA

fprintf('Load parameters \n')
[filename,folderpath] = uigetfile;
filepath = fullfile(folderpath, filename);
load(filepath)

fprintf('Load dataset to fit \n')
[filename,folderpath] = uigetfile;
filepath = fullfile(folderpath, filename);
load(filepath)

choice = menu(['Are you fitting G prime (signle power law)' ...
    ' or G second (double power law):'],"G' ",'G" ');

frequencies_number = ExtractFreq(data_organized);
if choice == 1
    flip_G(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:)); %G'
elseif choice == 2
    flip_G(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:)); %G"
end
[G(:,:), median(1,:), CI] = GetStatistics(flip_G,1,false);

freq = num2str(frequencies_number);
[idx,tf] = listdlg("PromptString","Select an Amplitude",...
    "SelectionMode","single","ListString",freq);
data(1,:) = G(:,idx);
noNaN_data = data(~isnan(data));
noNaN_data = rmoutliers(noNaN_data,"percentiles",[10,90]);

amp_idx = 1; %temp solution
if choice == 1
    ref_value = coeff_power1(amp_idx,1)*frequencies_number(idx,1)^(coeff_power1(amp_idx,2)); %G'
elseif choice == 2
    ref_value = coeff_power2(amp_idx,1)*frequencies_number(idx,1)^coeff_power2(amp_idx,2) + ...
        coeff_power2(amp_idx,3)*frequencies_number(idx,1)^coeff_power2(amp_idx,4); %G"
end

for i = 1:size(noNaN_data,2)
    residues(1,i) = noNaN_data(1,i) - ref_value;
end

edges=[-1000 -750 -200 200 750 1000];
histogram(residues)