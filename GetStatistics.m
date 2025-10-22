function [vector, median_vector, CI_vector] = GetStatistics(flip_vector,i)

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
        fprintf('%d \n', j)
    end

    %Getting the confidence interval for G' 
    for j = 1:size(vector,2)
        n_NaN_prime = numnan(vector(:,j));
        standard_error_prime = nanstd(vector(:,j))/sqrt(size(vector,2)-n_NaN_prime);
        t_score_prime = tinv([0.025 0.975], size(vector,2)-1-n_NaN_prime);
        CI_vector(i,j,:) = nanmean(vector(:,j)) + t_score_prime*standard_error_prime; %CI(i,j,1) has lower limit, CI(i,j,2) has the upper limit
    end    

end