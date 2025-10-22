function [frequencies_number] = ExtractFreq(data_organized)
    %EXTRACTING FREQUENCIES
    
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
end