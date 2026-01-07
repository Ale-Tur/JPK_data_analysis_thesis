function [suffix] = ExtractName(filepath,condition)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if matches(condition,'amplitude')
     tokens = regexp(filepath, '(\d+[A-Z])', 'tokens');
     if ~isempty(tokens)
        suffix = string(tokens{1}{1});
     else 
         suffix = '25A';
     end
elseif matches(condition,'drugs')
    fprintf('Select the part of the path with the drug name: \n')
    separated_filepath = strsplit(filepath,'\');
    fprintf('Select drug name suffix \n')
    [indx] = listdlg('ListString',separated_filepath);
    temp_string = string(separated_filepath{1,indx});
    separated2_filepath = strsplit(temp_string,'_');
    [indx] = listdlg('ListString',separated2_filepath);
    suffix = string(separated2_filepath(1,indx));
end

end