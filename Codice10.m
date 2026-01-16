clc
clear 

%PASSARE I FARMACI IN QUESTO ORDINE QUANDO ESTRAGGO PARAMETRI PER ALL:
%BASAL, DEFACTINIB, IBRUTINIB, CYTOCALASINA-D (mo sto passando solo basal
%ibr e cyto, da modificare)

experiments = {'amplitude','drugs'};
[indx_exp] = listdlg('ListString',experiments,'PromptString',...
    'Choose the type of data to analyze');

check = false;
fprintf('Pass all parameters, both medians and all. \nPass also all the cint. \n')
while ~check
    if matches(experiments(indx_exp),'amplitude')
        [filename,folderpath] = uigetfile('AmplitudeAnalysis\Data\Parameters','*.mat');
    elseif matches(experiments(indx_exp),'drugs')
        [filename,folderpath] = uigetfile('FarmaceuticalAnalysis\Data\Parameters','*.mat');
    end
    if isequal(filename, 0)
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        condition_power1 = strfind(filepath, 'all_coeff_power1');
        condition_power2 = strfind(filepath, 'all_coeff_power2');
        condition_cint1 = strfind(filepath, 'all_cint_power1');
        condition_cint2 = strfind(filepath, 'all_cint_power2');
        fprintf('%s \n', filename)
        load(filepath)
        if ~isempty(condition_power1)
            all_coeff_power1 = all_coeff;
            clear all_coeff
        elseif ~isempty(condition_power2)
            all_coeff_power2 = all_coeff;
            clear all_coeff
        elseif ~isempty(condition_cint1)
            all_cint_power1 = all_cint;
            clear all_cint
        elseif ~isempty(condition_cint2)
            all_cint_power2 = all_cint;
            clear all_cint
        end
    end
end

for i=1:size(all_coeff_power1,2)
    all_coeff_power1_mat = cell2mat(all_coeff_power1(1,i));
    num_NaN = sum(isnan(all_coeff_power1_mat(:,1)));
    all_coeff_power1_mat = all_coeff_power1_mat(~isnan(all_coeff_power1_mat));
    size_power1 = [size(all_coeff_power1{1,i},1)-num_NaN, size(all_coeff_power1{1,i},2)];
    all_coeff_power1_mat = reshape(all_coeff_power1_mat,size_power1);
    boot_median_power1 = bootstrp(5000, @median, all_coeff_power1_mat);
    CI_power1(:,1:2,i) = prctile(boot_median_power1, [12.5 87.5]);

    all_coeff_power2_mat = cell2mat(all_coeff_power2(1,i));
    num_NaN = sum(isnan(all_coeff_power2_mat(:,1)));
    all_coeff_power2_mat = all_coeff_power2_mat(~isnan(all_coeff_power2_mat));
    size_power2 = [size(all_coeff_power2{1,i},1)-num_NaN, size(all_coeff_power2{1,i},2)];
    all_coeff_power2_mat = reshape(all_coeff_power2_mat,size_power2);
    boot_median_power2 = bootstrp(5000, @median, all_coeff_power2_mat);
    CI_power2(:,1:4,i) = prctile(boot_median_power2, [12.5 87.5]);
end

f1 = @(x,a,b) a*x.^b;
f2 = @(x,c,d,e,f) c*x.^d + e*x.^f;
func = @(x,a,b,c,d,e,f) f1(x,a,b) - f2(x,c,d,e,f);

num_par = size(coeff_power1,1); %This can be amplitude or drug treatments
for i=1:num_par
    a = coeff_power1(i,1); b = coeff_power1(i,2);
    c = coeff_power2(i,1); d = coeff_power2(i,2);
    e = coeff_power2(i,3); f = coeff_power2(i,4);
    a_min = cint_power1(1,1,i); b_min = cint_power1(1,2,i);
    c_min = cint_power2(1,1,i); d_min = cint_power2(1,2,i);
    e_min = cint_power2(1,3,i); f_min = cint_power2(1,4,i);
    a_max = cint_power1(2,1,i); b_max = cint_power1(2,2,i);
    c_max = cint_power2(2,1,i); d_max = cint_power2(2,2,i);
    e_max = cint_power2(2,3,i); f_max = cint_power2(2,4,i);
    % a_min = CI_power1(1,1,i); b_min = CI_power1(1,2,i);
    % c_min = CI_power2(1,1,i); d_min = CI_power2(1,2,i);
    % e_min = CI_power2(1,3,i); f_min = CI_power2(1,4,i);
    % a_max = CI_power1(2,1,i); b_max = CI_power1(2,2,i);
    % c_max = CI_power2(2,1,i); d_max = CI_power2(2,2,i);
    % e_max = CI_power2(2,3,i); f_max = CI_power2(2,4,i);
    temp_func = @(x) func(x,a,b,c,d,e,f);
    temp_func_min = @(x) func(x,a_min,b_min,c_min,d_min,e_min,f_min);
    temp_func_max = @(x) func(x,a_max,b_max,c_max,d_max,e_max,f_max);
    %Forse posso joinare freq in un vettore/tensore error
    try freq_intersect_median(i,1) = fzero(temp_func,[1 500]); end
    try freq_error(i,1) = fzero(temp_func_min,[1 500]); 
    catch fprintf('no fzero min for %d-th iteration \n', i); end
    try freq_error(i,2) = fzero(temp_func_max,[1 500]);
    catch fprintf('no fzero max for %d-th iteration \n', i); end
end
%This 2 cycle can be joined, but to join them check carefully a,b,c,d,e,f
%how they are initialized 
for i=1:num_par
    temp_all_coeff1 = all_coeff_power1{1,i};
    temp_all_coeff2 = all_coeff_power2{1,i};
    num_cells = size(temp_all_coeff1,1);
    for j=1:num_cells
        a = temp_all_coeff1(j,1); b = temp_all_coeff1(j,2);
        c = temp_all_coeff2(j,1); d = temp_all_coeff2(j,2);
        e = temp_all_coeff2(j,3); f = temp_all_coeff2(j,4);
        if any(isnan([a b c d e f]))
            temp_freq_intersect(1,j) = NaN;
        else
            temp_func = @(x) func(x,a,b,c,d,e,f);
            try temp_freq_intersect(1,j) =  fzero(temp_func,[1 500]);
            catch temp_freq_intersect(1,j) = NaN;
            end
        end
    end
    all_freq{i,1} = temp_freq_intersect(:,:);
    freq_intersect_all(i,1) = nanmedian(temp_freq_intersect(1,:));
    col = temp_freq_intersect.';
    col = col(~isnan(col));
    boot_medians = bootstrp(5000, @median, col);
    CI(1,i,1:2) = prctile(boot_medians, [12.5 87.5]);
    CI_freq(i,1) = CI(1,i,1);            
    CI_freq(i,2) = CI(1,i,2);           
    clear temp_freq_intersect
    clear temp_freq_intersect
end


lower = freq_intersect_all - CI_freq(:,1);
upper = CI_freq(:,2) - freq_intersect_all;
c1 = uisetcolor([0 0 1]);
pFig1 = figure;
%mettere [1,2,3,4,5,6] per amp e [1,2,3] per drugs se ho solo 3 drugs
errorbar([1,2,3],freq_intersect_all,lower,upper,'o','MarkerEdgeColor',c1,'MarkerFaceColor',c1)
title('Frequency at which \eta = 1, calculated from all data')
ylabel('\bf{Frequncy [Hz]}')
% xlabel('\bf{Amplitude}')
% xticklabels({'25nm','50nm','100nm','150nm','200nm','250nm'})
% xlim([0.5,6.5])
ax1 = gca;
ax1.PlotBoxAspectRatio = [1,1,1];
xticks([1 2 3 ])
xticklabels({'\bf basal','\bf ibr','\bf cyto-d'})
xlim([0.5,3.5])
% ylim([50,300])
grid('on')



% FREQ ERROR QUI è SBAGLIATO, NON è DA AGGIUNGERE COME FA, MA TIPO
% FREQ_ERROR(1,1) = 186, QUELLO è ERRORE INFERIORE, TIPO SE HO 286HZ IL LIM
% INFERIORE è 186 Hz TIPO
pFig2 = figure;
% plot(freq_intersect_median,'o','MarkerEdgeColor',c1,'MarkerFaceColor',c1)
%MODO GIUSTO DI PLOTTARE L'ERRORE PER COME LO TROVO
plot(freq_intersect_median,'o','MarkerEdgeColor',c1,'MarkerFaceColor',c1)
hold on
plot(freq_error(:,2),'o','Marker','square','MarkerEdgeColor',c1,'MarkerFaceColor',c1) %inf
hold on
plot(freq_error(:,1),'o','Marker','diamond','MarkerEdgeColor',c1,'MarkerFaceColor',c1) %sup
title('Frequency at which \eta = 1, found for median values')
ylabel('Frequncy [Hz]')
% xticklabels({'25nm','50nm','100nm','150nm','200nm','250nm'})
% xlim([0.5,6.5])
xticks([1 2 3 ])
xticklabels({'basal','ibr','cyto-d'})
xlim([0.5,3.5])
% ylim([50,300])
grid('on')

save("freq_intersection_FromMedian", 'freq_intersect_median')
save("all_freq_intersection",'all_freq')
save("freq_intersection_FromAll", 'freq_intersect_all')

