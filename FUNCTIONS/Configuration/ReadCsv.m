function [ErrorMessage , Data, Date, Code, Loss, PorReturn] = ReadCsv(NameFile)

%% Initial Weitbar
warning off 
ErrorMessage    = 'Successful Run';
try
    
    %% Load Data
    ID_File     = fopen(NameFile,'r');
    Linetext    = fgetl(ID_File);
    Tmp         = strsplit(Linetext,',');
    Loss        = str2double(Tmp{2});

    Linetext    = fgetl(ID_File);
    Tmp         = strsplit(Linetext,',');
    PorReturn   = str2double(Tmp{2});

    Linetext    = fgetl(ID_File);
    Tmp         = strsplit(Linetext,',');
    Code        = cellfun(@str2num,Tmp(2:end));
    fclose(ID_File);

    ID_File     = fopen(NameFile,'r');
    Date    = textscan(ID_File,['%{dd-MM-yyyy}D',repmat('%f',1,length(Code))],'Delimiter',',','Headerlines',3);
    fclose(ID_File);
    Data    = cell2mat(Date(2:end));
    Date    = Date{1};
    
catch
    ErrorMessage    = ['The ',Name,'.csv Not Found'];
end
