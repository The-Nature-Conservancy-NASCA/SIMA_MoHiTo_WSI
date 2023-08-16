function [ErrorMessage, Data, Date, Code, TypeCrop, TimeCrop, Loss, PorReturn] = ReadCsv_Crop(NameFile)

%% Initial Weitbar
warning off 
ErrorMessage    = 'Successful Run';
try
    
    %% Load Data
    ID_File     = fopen(NameFile,'r');
    Linetext    = fgetl(ID_File);
    Count       = 1;
    while Count < 6
        if (Count == 1)
            Tmp         = strsplit(Linetext,',');
            TypeCrop  = Tmp{2};
        elseif (Count == 2)
            Tmp         = strsplit(Linetext,',');
            TimeCrop = str2double(Tmp{2});
        elseif (Count == 3)
            Tmp         = strsplit(Linetext,',');
            Loss = str2double(Tmp{2});
        elseif (Count == 4)
            Tmp         = strsplit(Linetext,',');
            PorReturn = str2double(Tmp{2});
        elseif (Count == 5)
            Tmp    = strsplit(Linetext,',');
            Code   = cellfun(@str2num,Tmp(2:end));
        end

        Count = Count + 1;
        Linetext    = fgetl(ID_File);
    end
    fclose(ID_File);

    ID_File     = fopen(NameFile,'r');
    Date    = textscan(ID_File,['%{dd-MM-yyyy}D',repmat('%f',1,length(Code))],'Delimiter',',','Headerlines',5);
    fclose(ID_File);
    Data    = cell2mat(Date(2:end));
    Date    = Date{1};
    
catch
    ErrorMessage    = ['The ',NameFile,' Not Found'];
end
