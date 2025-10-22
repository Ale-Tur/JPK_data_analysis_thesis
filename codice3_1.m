clc
clear

%This code can be easily used for both G' and G"

i = 1;
check = false;
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

        %Getting the right Parameters, in this case the G'
        % flip_G(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:)); %G'
        flip_G(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:)); %G"

        [G(:,:), median(i,:), CI] = GetStatistics(flip_G,i);

        %Plotting the medians and the CI
        c = uisetcolor;
        f1 = errorbar(frequencies_number(:,1),median(i,:),CI(i,:,1),CI(i,:,2),[],[],...
            '-o','Color',c,'MarkerFaceColor',c);
        xlabel('Frequencies [Hz]')
        ylabel('G* [Pa]')
        hold on

        % legend_array(1,i) = ExtractNameAmplitude(filename);

    end
    %Those are data that are already there, I really don't need them
    clear flip_G, clear G
    i = i+1;
end
% legend(legend_array);