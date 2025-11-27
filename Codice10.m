clc
clear 

%PASSARE I FARMACI IN QUESTO ORDINE QUANDO ESTRAGGO PARAMETRI PER ALL:
%BASAL, DEFACTINIB, IBRUTINIB, CYTOCALASINA-D

check = false;
while ~check
    [filename, folderpath] = uigetfile;
    if isequal(filename, 0)
        check = true;
    else
        filepath = fullfile(folderpath, filename);
        condition_power1 = strfind(filepath, 'all_coeff_power1');
        condition_power2 = strfind(filepath, 'all_coeff_power2');
        if ~isempty(condition_power1)
            load(filepath)
            all_coeff_power1 = all_coeff;
            clear all_coeff
        elseif ~isempty(condition_power2)
            load(filepath)
            all_coeff_power2 = all_coeff;
            clear all_coeff
        else
            load(filepath)
        end
    end
end

f1 = @(x,a,b) a*x.^b;
f2 = @(x,c,d,e,f) c*x.^d + e*x.^f;
func = @(x,a,b,c,d,e,f) f1(x,a,b) - f2(x,c,d,e,f);

num_par = size(coeff_power1,1); %This can be amplitude or drug treatments
for i=1:num_par
    a = coeff_power1(i,1); b = coeff_power1(i,2);
    c = coeff_power2(i,1); d = coeff_power2(i,2);
    e = coeff_power2(i,3); f = coeff_power2(i,4);
    temp_func = @(x) func(x,a,b,c,d,e,f);
    try freq_intersect_median(i,1) = fzero(temp_func,[1 500]); end
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
    clear temp_freq_intersect
end

c1 = uisetcolor([0 0 1]);
pFig1 = figure;
plot(freq_intersect_all,'o','MarkerEdgeColor',c1,'MarkerFaceColor',c1)
title('Median Frequency at which \eta = 1, for all cells')
ylabel('Frequncy [Hz]')
% xticklabels({'25nm','50nm','100nm','150nm','200nm','250nm'})
% xlim([0.5,6.5])
xticks([1 2 3 4])
xticklabels({'basal','def','ibr','cyto-d'})
xlim([0.5,4.5])
ylim([50,300])
grid('on')

pFig2 = figure;
plot(freq_intersect_median,'o','MarkerEdgeColor',c1,'MarkerFaceColor',c1)
title('Frequency at which \eta = 1, found for median values')
ylabel('Frequncy [Hz]')
% xticklabels({'25nm','50nm','100nm','150nm','200nm','250nm'})
% xlim([0.5,6.5])
xticks([1 2 3 4])
xticklabels({'basal','def','ibr','cyto-d'})
xlim([0.5,4.5])
ylim([50,300])
grid('on')

save("freq_intersection_FromMedian", 'freq_intersect_median')
save("all_freq_intersection",'all_freq')
save("freq_intersection_FromAll", 'freq_intersect_all')