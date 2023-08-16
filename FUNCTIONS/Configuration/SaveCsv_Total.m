function SaveCsv_Total(NameFile, Code, Data, Date)
                
Code    = reshape(repmat(Code',length(Date),1),[],1);
Data    = reshape(Data,[],1);
Date    = repmat([year(Date) month(Date)],length(unique(Code)),1);

ID_File = fopen( NameFile, 'w');
fprintf(ID_File,'%s\n','Code,Year,Month,Value');
fprintf(ID_File,'%d,%d,%d,%.2f\n',[Code Date Data]');
fclose(ID_File);

end

% function SaveCsv_Total(NameFile, Code, Data, Date)
%                 
% ID_File = fopen( NameFile, 'w');
% 
% Name = 'Date';
% for i = 1:length((Code))
%     Name = [Name,',',num2str(Code(i))]; 
% end
% fprintf(ID_File,'%s\n',Name);
% 
% for i = 1:length(Date)
%     fprintf(ID_File,'%s', datestr(Date(i),'dd-mm-yyyy'));
%     fprintf(ID_File, [repmat(',%0.1f',1,length(Code)),'\n'],Data(i,:));
% end
% fclose(ID_File);
% 
% end