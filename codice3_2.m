clc
clear

%This code can be easily used for both G' and G", with fit

i = 1;
check = false;
choice = menu(['Are you fitting G prime (signle power law)' ...
    ' or G second (double power law):'],"G' ",'G" ');
all_coeff = {};
while ~check
    
    [filename, folderpath] = uigetfile;
    fprintf("%s \n",filename)
    if isequal(filename, 0)

        fprintf('The user selected all the data \n');
        check = true;

    else
        filepath = fullfile(folderpath, filename);
        load(filepath)

        %Extract Freq.
        frequencies_number = ExtractFreq(data_organized);

        %Getting the right Parameters, toggle line based on G' or G"
        if choice == 1
            flip_G(:,:) = cell2mat(data_organized(2:size(data_organized,1),23,:)); %G'
        elseif choice == 2
            flip_G(:,:) = cell2mat(data_organized(2:size(data_organized,1),24,:)); %G"
        end
        
        [G(:,:), median(i,:), CI(i,:,:)] = GetStatistics(flip_G,i,true);

        %Plotting the medians and the CI
        c = uisetcolor;
        f1 = errorbar(frequencies_number(:,1),median(i,:),CI(i,:,1),CI(i,:,2),[],[],...
            'o','Color',c,'MarkerFaceColor',c);
        xlabel('Frequencies [Hz]')
        ylabel('G* [Pa]')
        hold on

        % legend_array(1,i) = ExtractNameAmplitude(filename);

        x_fit = frequencies_number(1,1):1:frequencies_number(size(frequencies_number,1),1);
        if choice == 1
            %For fit all of cells
            for jj=1:size(G,1)
                if anynan(G(jj,:)) == false
                    fit_all_power1 = fit(frequencies_number(:,1),(G(jj,:)).','power1');
                    temp_coeff(jj,:) = coeffvalues(fit_all_power1);
                    temp_cint(:,:,jj) = confint(fit_all_power1,0.5);
                else
                    temp_coeff(jj,:) = NaN(1,2);
                    temp_cint(:,:,jj) = NaN(2,2); 
                end
            end
            all_coeff{i} = temp_coeff;
            all_cint{i} = temp_cint;
            clear temp_coeff; clear temp_cint

            %For fit median
            c_1 = uisetcolor;
            fit_power = fit(frequencies_number(:,1),(median(i,:)).','power1');
            coeff_power1(i,:) = coeffvalues(fit_power);
            cint_power1(:,:,i) = confint(fit_power,0.5);
            y_fit(:,1) = coeff_power1(i,1)*x_fit.^(coeff_power1(i,2));
            f2 = plot(y_fit,'Color',c_1, 'LineWidth',0.7,'HandleVisibility','off');
            % legend_array(2,i) = ExtractNameAmplitude(filename) + 'fit';
        
        %DA CORREGGERE (dovrebbe essre corretto)
        elseif choice == 2

            fo = fitoptions('Method', 'NonLinearLeastSquares', 'StartPoint', [50, 1.5, 200, 0.5], 'lower', [1,0,1,0]);
            ft = fittype('a*x^b + c*x^d','independent', 'x', 'coefficients', {'a','b','c','d'},'options',fo);
            %For fit all of cells
            for jj=1:size(G,1)
                if anynan(G(jj,:)) == false
                    fit_all_power2 = fit(frequencies_number(:,1),(G(jj,:)).',ft);                 
                    temp_coeff(jj,:) = coeffvalues(fit_all_power2);
                    temp_cint(:,:,jj) = confint(fit_all_power2,0.5); %?? check se è giusto
                else
                    temp_coeff(jj,:) = NaN(1,4);
                    temp_cint(:,:,jj) = NaN(2,4); %?? check se è giusto
                end
            end
            all_coeff{i} = temp_coeff;
            all_cint{i} = temp_cint;
            clear temp_coeff; clear temp_cint

            %For fit median
            c_1 = uisetcolor;
            fit_power2 = fit(frequencies_number(:,1),(median(i,:)).',ft);
            coeff_power2(i,:) = coeffvalues(fit_power2);
            cint_power2(:,:,i) = confint(fit_power2,0.5);
            y_fit_2(:,1) = coeff_power2(i,1)*x_fit.^(coeff_power2(i,2))...
                +coeff_power2(i,3)*x_fit.^(coeff_power2(i,4));
            f2 = plot(y_fit_2,'--', 'Color', c_1, 'LineWidth',0.7,'HandleVisibility','off');
        end
    end
    %Those are data that are already there, I really don't need them
    clear flip_G, clear G
    i = i+1;
end
% legend_array = reshape(legend_array, [], 1);
% legend(legend_array);

if choice == 1
    save("Output\all_coeff_power1","all_coeff")
    save("Output\all_cint_power1","all_cint")
    save("Output\all_coeff_median_power1","coeff_power1")
    save("Output\all_cint_median_power1","cint_power1")
elseif choice == 2
    save("Output\all_coeff_power2","all_coeff")
    save("Output\all_cint_power2","all_cint")
    save("Output\all_coeff_median_power2","coeff_power2")
    save("Output\all_cint_median_power2","cint_power2")
end