function SaveCsv_Crop(NameFile, Code, Data, Date, TypeCrop, TimeCrop, Loss, PorReturn)
                
ID_File = fopen( NameFile, 'w');

fprintf(ID_File,'%s\n',['TypeCrop,',TypeCrop]);
fprintf(ID_File,'%s\n',['TimeCrop,',num2str(TimeCrop)]);
fprintf(ID_File,'%s\n',['Loss,',num2str(Loss)]);
fprintf(ID_File,'%s\n',['PorReturn,',num2str(PorReturn)]);

Name = 'Date';
for i = 1:length((Code))
    Name = [Name,',',num2str(Code(i))]; 
end
fprintf(ID_File,'%s\n',Name);

for i = 1:length(Date)
    fprintf(ID_File,'%s', datestr(Date(i),'dd-mm-yyyy'));
    fprintf(ID_File, [repmat(',%0.1f',1,length(Code)),'\n'],Data(i,:));
end
fclose(ID_File);

end