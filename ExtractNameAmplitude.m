function [suffix] = ExtractNameAmplitude(filename)
    % Extracts the amplitude pattern from the filename
    % Looks for digits followed by a single uppercase letter
    tokens = regexp(filename, '(\d+[A-Z])', 'tokens');
    
    if ~isempty(tokens)
        suffix = string(tokens{1}{1});  % take the first match
    else
        suffix = '';  % return empty if nothing found
    end
end