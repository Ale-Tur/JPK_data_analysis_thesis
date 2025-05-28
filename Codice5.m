save('116hz_cell4_05_16',"forcesave116")

force_array = forcesave116.TEXT;
forcearray_clean = force_array(~isnan(force_array));

plot(forcearray_clean)