function WriteError(NameFile, ErrorMessage)

% ----------------------------------
ID_File   = fopen(NameFile,'w');
fprintf(ID_File, ErrorMessage);
fclose(ID_File);
% ----------------------------------