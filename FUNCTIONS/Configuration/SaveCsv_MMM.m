function SaveCsv_MMM(NameFile, Code, Data)
                
ID_File = fopen( NameFile, 'w');

Date = (1:12)';
Date = repmat(Date,length(Code),1);
Code = reshape(repmat(Code',12,1),[],1);
Data = reshape(Data(:,1:12)',[],1);

fprintf(ID_File,'%s\n','Code,Month,Value');
fprintf(ID_File,'%d,%d,%.2f\n',[Code Date Data]');
fclose(ID_File);

end

% function SaveCsv_MMM(NameFile, Code, Data)
%                 
% ID_File = fopen( NameFile, 'w');
% 
% Name = 'ArcID,ENE,FEB,MAR,ABR,MAY,JUN,JUL,AGO,SEP,OCT,NOV,DEC,YEAR';
% fprintf(ID_File,'%s\n',Name);
% 
% fprintf(ID_File, ['%d', repmat(',%0.1f',1,13),'\n'],[Code, Data]');
% fclose(ID_File);
% 
% end