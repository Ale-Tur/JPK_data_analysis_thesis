% clc
% clear

% save('1hz_cell7_06_09',"forcesave1")

forcesave = forcesave2025;

deflection = forcesave.TEXT;
tip_position = forcesave.VarName1;
height = forcesave.EXPORT;
SmoothMeasured_height = forcesave.VarName4;
measured_height = forcesave.VarName5;
time = forcesave.VarName6;

plot(time,tip_position*10^6 + 1.441, 'red') %1.323 %1.466
hold on
plot(time,measured_height*10^6 + 1.441, 'blue')


pause

plot(time,deflection*10^9)

pause

yyaxis left
plot(time,deflection*10^9,'blue')
hold on
yyaxis right
plot(time, tip_position*10^6 + 1.426, 'red')      

% %PER CALIBRATION CURVES
% forcesave = forcesave2025;
% 
% deflection = forcesave.VerticalDeflection;
% height_MS = forcesave.Height_measured_smoothed_;
% height = forcesave.Height;
% height_M = forcesave.Height_measured;
% time = forcesave.SeriesTime;
% time2 = forcesave.SegmentTime;
% 
% plot(height,deflection)
% 
% approach_height = height_MS(1:10000);
% disengagment_height = height_MS(10070:size(height_MS,1));
% 
% plot(approach_height,deflection(1:10000),'blue')
% hold on
% plot(disengagment_height,deflection(10070:size(height_MS,1)),'red')




