clc, clear

check = false;

%AGGIUNGERE ERRORE PER PARAMETRI???

fprintf('Select both the medians .mat file and the cell with all the data \n')
while ~check
    %Getting the filepath through user file selection
    [filename, folderpath] = uigetfile('*.mat');
    if isequal(filename, 0)
        fprintf('User finshed file selection. \n');
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        load(filepath)
    end
end


choice = menu(['Are we studying the coeff for all the cells' ...
    ' or the medians'],'All the cells','Medians');

amp_ind = ["25nm" "50nm" "100nm" "150nm" "200nm" "250nm"];
amp_ind_num = [25, 50, 100, 150, 200, 250];

if choice == 1

    ch_1 = listdlg('ListString',["All", "One amplitude"],...
        'PromptString', 'Work on all the amplitudes or one?',...
        'ListSize',[200,300]);
    if ch_1 == 1
        new_coeff = OrganizeCellParameters(all_coeff);
        for ii = 1:size(new_coeff,3)
            for jj =1:size(new_coeff,2)
                temp_vec = new_coeff{1,jj,ii};
                temp_vec(isnan(temp_vec)) = [];
                xvec = ones(size(temp_vec));
                xvec(:) = amp_ind_num(jj);
                boxchart(xvec, temp_vec, 'BoxWidth',5)
                set(gca,'XTick', amp_ind_num,'XTickLabel', amp_ind)
                hold on, clear temp_vec
                % scatter(amp_ind_num,coeff_power1(:,ii),'MarkerFaceColor',"r")
                scatter(amp_ind_num,coeff_power2(:,ii),'MarkerFaceColor',"r")
            end
            fprintf('Press any key in the command window \n')
            pause
        end
    elseif ch_1 == 2
        idx_amp = listdlg('ListString',amp_ind,'PromptString',...
            'Select Amplitude to display');
        temp_coeff_matrix = all_coeff{idx_amp};
        if size(all_coeff{1},2) == 2
            plot(temp_coeff_matrix(:,1),temp_coeff_matrix(:,2),'o')
            hold on, clear temp_coeff_matrix
            scatter(coeff_power1(idx_amp,1),coeff_power1(idx_amp,2),'MarkerFaceColor',"r")
        elseif size(all_coeff{1},2) == 4
            %Posso fare un grafico 1x2 tipo sopra con a,b e c,d???
            tiledlayout(1,2)
            nexttile
            scatter(temp_coeff_matrix(:,1),temp_coeff_matrix(:,2),'o')
            hold on,
            scatter(coeff_power2(idx_amp,1),coeff_power2(idx_amp,2),'MarkerFaceColor',"r")
            title('Parameters (a,b)')

            nexttile
            scatter(temp_coeff_matrix(:,3),temp_coeff_matrix(:,4),'o')
            hold on, clear temp_coeff_matrix
            scatter(coeff_power2(idx_amp,3),coeff_power2(idx_amp,4),'MarkerFaceColor',"r")
            title('Parameters (c,d)')

            sgtitle('Parameters from fit: ax^b + cx^d')
        end
    end

elseif choice == 2

    if size(all_coeff{1},2) == 2
        yyaxis left
        plot(amp_ind_num,coeff_power1(:,1),'-o')
        hold on
        yyaxis right
        plot(amp_ind_num,coeff_power1(:,2),'-o')
        set(gca,'XTick', amp_ind_num)
    elseif size(all_coeff{1},2) == 4
        tiledlayout(1,2)
        nexttile
        yyaxis left
        plot(amp_ind_num,coeff_power2(:,1),'-o')
        hold on
        yyaxis right
        plot(amp_ind_num,coeff_power2(:,2),'-o')
        set(gca,'XTick', amp_ind_num)
        title('Parameters (\color{blue}a\color{black},\color{orange}b\color{black})')

        nexttile
        yyaxis left
        plot(amp_ind_num,coeff_power2(:,3),'-o')
        hold on
        yyaxis right
        plot(amp_ind_num,coeff_power2(:,4),'-o')
        set(gca,'XTick', amp_ind_num)
        title('Parameters (\color{blue}c\color{black},\color{orange}d\color{black})')

        sgtitle('Parameters from fit: ax^b + cx^d')
    end

end