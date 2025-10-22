% clc
% clear

save('1hz_cell7_06_09',"forcesave1")

force_array = forcesave1.TEXT;
forcearray_clean = force_array(~isnan(force_array));

plot(forcearray_clean)


% heigth_1hz_25nm = forcesave1_25.VarName1;
% heigth_1hz_250nm = forcesave1_250.VarName1;
% 
% plot(heigth_1hz_250nm(14949:15763)*(10^7), 'Color',[1 0 0])
% hold on
% 
% plot(heigth_1hz_25nm(15422:16326)*(10^7)-6.68977, 'Color',[0 0 1])




