clc
clear

i = 1;
check = false;
colors = {};
G_prime = {};
G_second = {};
dataset_ID = [];

while ~check

    [filename, folderpath] = uigetfile;
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;

    else
        filepath = fullfile(folderpath, filename);
        load(filepath)
        
        frequencies_number = ExtractFreq(data_organized);
        flip_G_prime(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:)); %G'
        flip_G_second(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:)); %G"
        [temp_prime(:,:), median_prime(i,:), CI_prime] = GetStatistics(flip_G_prime,i);
        [temp_second(:,:), median_second(i,:), CI_second] = GetStatistics(flip_G_second,i);
        G_prime{i} = temp_prime;
        G_second{i} = temp_second;

        color_temp = uisetcolor();
        colors{i} = color_temp(:)';

        dataset_ID = [dataset_ID,ExtractNameAmplitude(filename)];
        % dataset_ID = [dataset_ID,"fit"];


    end
    i = i+1;
    clear temp_prime, clear temp_second
    clear flip_G_prime, clear flip_G_second
end

choice_1 = listdlg('ListString',["Medians", "Data"],...
        'PromptString', 'Do you want |G*| computed from all data or from medians?',...
        'ListSize',[200,300]);

num_dataset = numel(G_prime);
if choice_1 == 1
    
    fprintf('G* will be computed with the medians of the moduli \n' )
    mod_G(:,:) = sqrt(median_prime(:,:).^2 + median_second.^2); 

    fo = fitoptions('Method', 'NonLinearLeastSquares', 'StartPoint', [400, 0.1, 0.5, 0.1]);
    ft = fittype('a*x^b + c*x^d','independent', 'x', 'coefficients', {'a','b','c','d'},'options',fo);
    for ii = 1:num_dataset
        fit_power2 = fit(frequencies_number(:,1),(mod_G(ii,:)).',ft);
        coeff_power2(ii,:) = coeffvalues(fit_power2);
    end

    xdata = 1:1:max(frequencies_number);
    for ii = 1:num_dataset
        plot(frequencies_number,mod_G(ii,:),'-o','Color',colors{ii},'MarkerFaceColor',colors{ii})
        hold on
        plot(xdata,power2(coeff_power2(ii,:),xdata),'--','Color',colors{ii})
        hold on
    end
    xlabel('Frequency');
    ylabel('G* modulus');
    legend(dataset_ID, 'Location', 'bestoutside');


elseif choice_1 == 2

    fprintf('G* will be computed for each data and the obtained G* will be the median \n')
    mod_G = cell(size(G_prime));
    fo = fitoptions('Method', 'NonLinearLeastSquares', 'StartPoint', [400, 0.5, 0.5, 0.05]);
    ft = fittype('a*x^b + c*x^d','independent', 'x', 'coefficients', {'a','b','c','d'},'options',fo);
    
    for ii=1:num_dataset
        temp_prime = G_prime{1,ii};
        temp_second = G_second{1,ii};
        temp_G(:,:) = sqrt(temp_prime(:,:).^2 + temp_second(:,:).^2);
        mod_G{1,ii} = temp_G;
    
        median_mod_G(ii,:) = nanmedian(temp_G(:,:));
        % CI_mod_G(i,j,k), i=# of dataset, j=freq, k=lower or upper (1 or 2)
        CI_mod_G(ii,:,:) = ConfidenceInterval(temp_G);
        clear temp_prime, clear temp_second, clear temp_G
    end

    for ii = 1:num_dataset
        fit_power2 = fit(frequencies_number(:,1),(median_mod_G(ii,:)).',ft);
        coeff_power2(ii,:) = coeffvalues(fit_power2);
    end

    xdata = 1:1:max(frequencies_number);
    for ii = 1:num_dataset
        errorbar(frequencies_number,median_mod_G(ii,:),CI_mod_G(ii,:,1),CI_mod_G(ii,:,2),...
            'o','Color',colors{ii},'MarkerFaceColor',colors{ii})
        hold on
        plot(xdata,power2(coeff_power2(ii,:),xdata),'--','Color',colors{ii}, 'HandleVisibility','off')
        hold on
    end
    xlabel('Frequency [Hz]');
    ylabel('|G*|  [Pa]');
    legend(dataset_ID, 'Location', 'bestoutside');

end

save("Gmod_coeff_power2","coeff_power2")



function [y] = power2(parameter,xdata)
    y = parameter(1,1)*xdata.^parameter(1,2) ...
        + parameter(1,3)*xdata.^parameter(1,4);
end

function [CI] = ConfidenceInterval(matrix)
    for j = 1:size(matrix,2)
        n_NaN = numnan(matrix(:,j));
        standard_error = nanstd(matrix(:,j))/sqrt(size(matrix,2)-n_NaN);
        t_score = tinv([0.05 0.95], size(matrix,2)-1-n_NaN);
        %CI(j,1) has lower limit, CI(j,2) has the upper limit
        CI(j,:) = nanmean(matrix(:,j)) + t_score*standard_error;
    end
end