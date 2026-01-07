function [vector, median_vector, CI_vector] = GetStatistics(flip_vector,i, condition_25)

    %Control for values under zero
    for ii = 1:size(flip_vector,1)
        for jj = 1:size(flip_vector,2)
            if flip_vector(ii,jj) < 0
                flip_vector(ii,jj) = NaN;
            end
        end
    end

    %This command is needed to easily obtain G' and G'' vs frequencies
    vector = flip_vector.';

    for j = 1:size(vector,2)
        median_vector(1,j) = nanmedian(vector(:,j));
        % fprintf('%d \n', j)
    end

    % if condition_25 == false 
    %     %95 CI
    %     for j = 1:size(vector,2)
    %         col = vector(:,j);
    %         n = sum(~isnan(col));
    %         standard_error = nanstd(col) / sqrt(n);
    %         t_score = tinv([0.025 0.975], n-1); % 95% CI quantiles
    % 
    %         CI_vector(1,j,1) = nanmean(col) + t_score(1)*standard_error;  % lower
    %         CI_vector(1,j,2) = nanmean(col) + t_score(2)*standard_error;  % upper
    %     end    
    % elseif condition_25 == true
    %     % 75 CI
    %     for j = 1:size(vector,2)
    %         col = vector(:,j);
    %         n = sum(~isnan(col));                 
    %         standard_error = nanstd(col) / sqrt(n);           
    %         t_score = tinv([0.125 0.875], n-1); % 75% CI quantiles
    % 
    %         CI_vector(1,j,1) = nanmean(col) + t_score(1)*standard_error;   % lower
    %         CI_vector(1,j,2) = nanmean(col) + t_score(2)*standard_error;   % upper
    %     end
    % end
    nboot = 5000;
    if condition_25 == false
        ci_pct = [2.5 97.5];   % 95% CI
    else
        ci_pct = [12.5 87.5]; % 75% CI
    end
    for j = 1:size(vector,2)
        col = vector(:,j);
        boot_medians = bootstrp(nboot,@nanmedian,col);
        CI_vector(1,j,1:2) = prctile(boot_medians,ci_pct);
    end
end