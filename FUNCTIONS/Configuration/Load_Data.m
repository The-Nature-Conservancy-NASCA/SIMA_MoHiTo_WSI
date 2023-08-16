function [ErrorMessage, Data, Date, Code] = Load_Data(NameFile, Name)

%% Initial Weitbar
warning off 
ErrorMessage    = 'Successful Run';
try
    % Read Code
    ID_File     = fopen(NameFile, 'r');
    Data        = textscan(ID_File,'%f%f%f%f','Delimiter',',','Headerlines',1);
    fclose(ID_File);    
    
    Data        = [Data{1} Data{2} Data{3} Data{4}];
    Tmp         = unique(Data(:,1)); 
    n           = sum(Data(:,1) == Tmp(1)); 
    Code        = reshape(Data(:,1),n,[]);
    Code        = Code(1,:)';
    
    Date        = datetime(Data(1:n,2), Data(1:n,3), ones(size(Data(1:n,1)))); 
    Data        = reshape(Data(:,4),n,[]);    

catch
    ErrorMessage    = ['The ',Name,'.csv Not Found'];
end

% function [ErrorMessage, Data, Date, Code] = Load_Data(NameFile, Name)
% 
% %% Initial Weitbar
% warning off 
% ErrorMessage    = 'Successful Run';
% try
%     % Read Code
%     ID_File     = fopen(NameFile, 'r');
%     Linetext    = fgetl(ID_File);
%     Tmp         = strsplit(Linetext,',');        
%     Code        = cellfun(@str2num,Tmp(2:end));
%     fclose(ID_File);
% 
%     % Read Data and Date
%     ID_File     = fopen(NameFile,'r');
%     Date        = textscan(ID_File,['%{dd-MM-yyyy}D',repmat('%f',1,length(Code))],'Delimiter',',','Headerlines',1);
%     fclose(ID_File); 
%     Data = cell2mat(Date(2:end));
%     Date = Date{1};
%     Date = datetime(datestr(Date),'InputFormat','dd-MM-yyyy');
% 
% catch
%     ErrorMessage    = ['The ',Name,'.csv Not Found'];
% end