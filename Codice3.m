clc
clear

i = 1;
legend_inx = 1;
check = false;
while ~check

    [filename, folderpath] = uigetfile;
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;

    else
        filepath = fullfile(folderpath, filename);
        load(filepath)

        %% EXTRACTING FREQUENCIES

        %One can extract frequencies just from one dataset assuming that all the
        %data are taken at the same frequencies
        
        %Contains the name of the curves, to extract frequencies
        temp_name_vector = string(data_organized(:,1,1));
        
        %Searching for the 'Filename' legend in data, because how the first code is
        %done this is needed
        index_filename = cell2mat(strfind(temp_name_vector,'Filename'));
        
        %If there is the legend 'Filename', we eliminate it
        if ~isempty(index_filename)
            temp_name_vector(index_filename,:) = [];
        end

        obtained_frequencies = regexp(temp_name_vector(:,1), '\d*.\d*Hz', 'Match');
        
        frequencies_number = regexp(string(obtained_frequencies(:,1)), '\d*.\d', 'Match');
        frequencies_number = str2double(string(frequencies_number));

        %% Getting statistics

        %Getting the right Parameters, in this case the G' and G''
        flip_Gprime(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:));
        flip_Gsecond(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:));
        
        %This command is needed to easily obtain G' and G'' vs frequencies
        Gprime = flip_Gprime.';
        Gsecond = flip_Gsecond.';

        %Getting the median for G' (separeted for future errors check
        %maybe?)
        for j = 1:size(Gprime,2)
            median_Gprime(i,j) = nanmedian(Gprime(:,j));
            fprintf('%d \n', j)
        end

        %Getting the median for G" (separeted for future errors check
        %maybe?)
        for j = 1:size(Gsecond,2)
            median_Gsecond(i,j) = nanmedian(Gsecond(:,j));
        end        
        
        %Getting the confidence interval for G' 
        for j = 1:size(Gprime,2)
            n_NaN_prime = numnan(Gprime(:,j));
            standard_error_prime = nanstd(Gprime(:,j))/sqrt(size(Gprime,2)-n_NaN_prime);
            t_score_prime = tinv([0.025 0.975], size(Gprime,2)-1-n_NaN_prime);
            CI_prime(i,j,:) = nanmean(Gprime(:,j)) + t_score_prime*standard_error_prime; %CI(i,j,1) has lower limit, CI(i,j,2) has the upper limit
        end

        for j = 1:size(Gsecond,2)
            n_NaN_second = numnan(Gsecond(:,j));
            standard_error_second = nanstd(Gsecond(:,j))/sqrt(size(Gsecond,2)-n_NaN_second);
            t_score_second = tinv([0.025 0.975], size(Gprime,2)-1-n_NaN_second);
            CI_second(i,j,:) = nanmean(Gsecond(:,j)) + t_score_second*standard_error_second; %CI(i,j,1) has lower limit, CI(i,j,2) has the upper limit
        end
        
        %% Plotting G'
        c = uisetcolor;

        %Fitting both single and double exp
        fit_Gprime_power1 = fit(frequencies_number(:,1),(median_Gprime(i,:)).','power1');
        fo = fitoptions('Method', 'NonLinearLeastSquares', 'StartPoint', [1, 1, 1, 1]);
        ft = fittype('a*x^b + c*x^d','independent', 'x', 'coefficients', {'a','b','c','d'},'options',fo);
        fit_Gprime_power2 = fit(frequencies_number(:,1),(median_Gprime(i,:)).',ft);
        coeff_Gprime_power1(i,:) = coeffvalues(fit_Gprime_power1);
        coeff_Gprime_power2(i,:) = coeffvalues(fit_Gprime_power2);
        
        %Plotting the medians and the CI
        f1 = errorbar(frequencies_number(:,1),median_Gprime(i,:),CI_prime(i,:,1),CI_prime(i,:,2),[],[],...
            'o','Color',c,'MarkerFaceColor',c);
        xlabel('Frequencies [Hz]')
        ylabel('G* [Pa]')
        hold on

        %Plotting the fits
        c_1 = uisetcolor('Choose color for exp1 fit');
        x_fit = frequencies_number(1,1):1:frequencies_number(size(frequencies_number,1),1);
        y_fit(:,1) = coeff_Gprime_power1(i,1)*x_fit.^(coeff_Gprime_power1(i,2));
        f2 = plot(y_fit,'Color',c_1, 'LineWidth',0.7,'HandleVisibility','off');
        legend({'G exp1 fit'})
        hold on
        y_fit_2(:,1) = coeff_Gprime_power2(i,1)*x_fit.^(coeff_Gprime_power2(i,2))...
            +coeff_Gprime_power2(i,3)*x_fit.^(coeff_Gprime_power2(i,4));
        c_2 = uisetcolor('Choose color for exp2 fit');
        f3 = plot(y_fit_2,'--', 'Color', c_2, 'LineWidth',0.7,'HandleVisibility','off');
        hold on

        %% Plotting G"
        c_3 = uisetcolor;

        %Fitting both single and double exp
        fit_Gsecond_power1 = fit(frequencies_number(:,1),(median_Gsecond(i,:)).','power1');
        fit_Gsecond_power2 = fit(frequencies_number(:,1),(median_Gsecond(i,:)).',ft);
        coeff_Gsecond_power1(i,:) = coeffvalues(fit_Gsecond_power1);
        coeff_Gsecond_power2(i,:) = coeffvalues(fit_Gsecond_power2);
        
        %Plotting the medians and the CI
        f4 = errorbar(frequencies_number(:,1),median_Gsecond(i,:),CI_second(i,:,1),CI_second(i,:,2),[],[],...
            'o','Color',c_3,'MarkerFaceColor',c_3);
        hold on

        %Plotting the fits
        c_4 = uisetcolor('Choose color for exp1 fit');
        x_fit = frequencies_number(1,1):1:frequencies_number(size(frequencies_number,1),1);
        y_fit(:,1) = coeff_Gsecond_power1(i,1)*x_fit.^(coeff_Gsecond_power1(i,2));
        f5 = plot(y_fit,'Color',c_4, 'LineWidth',0.7,'HandleVisibility','off');
        hold on
        y_fit_2(:,1) = coeff_Gsecond_power2(i,1)*x_fit.^(coeff_Gsecond_power2(i,2))...
            +coeff_Gsecond_power2(i,3)*x_fit.^(coeff_Gsecond_power2(i,4));
        c_5 = uisetcolor('Choose color for exp2 fit');
        f6 = plot(y_fit_2,'--','Color', c_5, 'LineWidth',0.7,'HandleVisibility','off');
        hold on

        %Getting plot title
        if i == 1
            separated_filepath = strsplit(filepath,'\');
            [indx] = listdlg('ListString',separated_filepath);
            temp_string = string(separated_filepath{1,indx});
            separated2_filepath = strsplit(temp_string,'_');
            [indx] = listdlg('ListString',separated2_filepath);
            if indx == 1
                temp_title = separated2_filepath(indx);
                title(temp_title)
            else
                temp_title = separated2_filepath(1,indx(1));
                for j=2:size(indx,2)
                    temp_title = temp_title + ' ' + separated2_filepath(1,indx(j));
                    title(temp_title)
                end
            end
        else
            temp_title = temp_title + ' vs';
            separated_filepath = strsplit(filepath,'\');
            [indx] = listdlg('ListString',separated_filepath);
            temp_string = string(separated_filepath{1,indx});
            separated2_filepath = strsplit(temp_string,'_');
            [indx] = listdlg('ListString',separated2_filepath);
            if indx == 1
                temp_title = temp_title + ' ' + separated2_filepath(indx);
                title(temp_title)
            else
                temp_title = temp_title + ' ' + separated2_filepath(1,indx(1));
                for j=2:size(indx,2)
                    temp_title = temp_title + ' ' + separated2_filepath(1,indx(j));
                    title(temp_title)
                end
            end            
        end
        
        %Getting legend
        legend_promp = ["G'", 'G"'];
        for j=0:(size(legend_promp,2)-1)
            %fprintf('%d %d \n', j, j+legend_inx);
            legend_array(1,(j+legend_inx)) = legend_promp(1,j+1) + " " + separated2_filepath(1,indx(2));
        end 
        legend_inx = size(legend_array,2) + 1;
        clear separated_filepat, clear separated2_filepath
        clear temp_string

        clear Gprime; clear flip_Gprime,
        clear Gsecond; clear flip_Gsecond
    end
i = i+1;
end
legend(legend_array);