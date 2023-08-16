function [Data, Date, Code] = ReadCsv_Total(NameFile)

%% Load Data
ID_File     = fopen(NameFile,'r');

Linetext    = fgetl(ID_File);
Tmp         = strsplit(Linetext,',');
Code        = cellfun(@str2num,Tmp(2:end));
fclose(ID_File);

ID_File     = fopen(NameFile,'r');
Date    = textscan(ID_File,['%{dd-MM-yyyy}D',repmat('%f',1,length(Code))],'Delimiter',',','Headerlines',1);
fclose(ID_File);
Data    = cell2mat(Date(2:end));
Date    = Date{1};
