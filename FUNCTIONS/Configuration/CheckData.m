function [ErrorMessage, Data] = CheckData(UserData, Data, Date, Code, Name, varargin)

if 	nargin == 6
    ProgressBar = varargin{1};
end
    
%% Initial Weitbar
warning off 
ErrorMessage    = 'Successful Run';
try    
    % Check Date
    [id,PosiDate]   = ismember(UserData.Date,Date);
    if sum(id) ~= length(UserData.Date)
        ErrorMessage    = ['The dates of the ',Name,'.csv file are not in the defined ranges '...
                        'by Scenario'];
        if ~UserData.Terminal 
            close(ProgressBar)
        end
        return
    end              
    Data = Data(PosiDate,:);            

    % Check organized chronologically
    tmp = diff(PosiDate);
    if sum(tmp ~= 1)>0
        ErrorMessage    = ['The dates of the ',Name,'.csv file are not organized chronologically'];
        if ~UserData.Terminal 
            close(ProgressBar)
        end
        return
    end

    % Check Code
    [id,Posi]   = ismember(UserData.ArcID,Code);
    if sum(id) ~= length(UserData.ArcID)
        ErrorMessage    = ['The HUA Codes of the ',Name,'.csv file are not in the defined ranges '...
                        'by Configuration.MoHiTo File'];
        if ~UserData.Terminal 
            close(ProgressBar)
        end
        return
    end     
    Data = Data(:,Posi);          

    % Check NaN
    id = sum(sum(isnan(Data)));
    if id > 0
        ErrorMessage    = ['There are null ',Name,' values'];
        if ~UserData.Terminal 
            close(ProgressBar)
            errordlg(ErrorMessage,'!! Error !!')
        end
        return
    end 

    % Check Negative values
    id = sum(sum(Data < 0));
    if id > 0
        ErrorMessage    = ['There are negative ',Name,' values'];
        if ~UserData.Terminal 
            close(ProgressBar)
        end
        return
    end
    
catch ME
    ErrorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message); 
    
    if ~UserData.Terminal 
        close(ProgressBar)
    end
end
