function [ErrorMessage, UserData] = Load_Climate(UserData)
% -------------------------------------------------------------------------
% Matlab Version - R2018b 
% -------------------------------------------------------------------------
%                              BASE DATA 
% -------------------------------------------------------------------------
% The Nature Conservancy - TNC
% 
% Project     : Landscape planning for agro-industrial expansion in a large, 
%               well-preserved savanna: how to plan multifunctional 
%               landscapes at scale for nature and people in the Orinoquia 
%               region, Colombia
% 
% Team        : Tomas Walschburger 
%               Science Sr Advisor NASCA
%               twalschburger@tnc.org
% 
%               Carlos Andr�s Rog�liz 
%               Specialist in Integrated Analysis of Water Systems NASCA
%               carlos.rogeliz@tnc.org
%               
%               Jonathan Nogales Pimentel
%               Hydrology Specialist
%               jonathan.nogales@tnc.org
% 
% Author      : Jonathan Nogales Pimentel
% Email       : jonathannogales02@gmail.com
% Date        : November, 2017
% 
% -------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% If not, see http://www.gnu.org/licenses/.
% -------------------------------------------------------------------------
%                               DESCRIPTION 
% -------------------------------------------------------------------------
% 
% This function perform the calibration and validation of the ABDC-FP-D 
% Model through of the Shuffled complex evolution
% 
% -------------------------------------------------------------------------
%                               INPUT DATA
% -------------------------------------------------------------------------

%% Initial Weitbar
warning off 

ErrorMessage    = 'Successful Run';
try          
    
    %% -------------------------------------------------------------------------
    % Precipitation and Evapotranspiration
    % -------------------------------------------------------------------------
    NameCli = {'Precipitation','Evapotranspiration'};
    if ~UserData.Terminal 
        ProgressBar     = waitbar(0, 'Load Climate Data  ...');
        conto = 0.5;
    else
        disp('Load Climate Data  ...')
    end
    
    for ar = 1:2        
        NameFile    = fullfile(UserData.PathProject,'INPUTS',UserData.Scenarios,'Climate',[NameCli{ar},'.csv']);

        % Load Data
        [ErrorMessage, Data, Date, Code] = Load_Data(NameFile, NameCli{ar});
        
        [id, posi]  = ismember(Code, UserData.ArcID);
        Data        = Data(:,posi(id));
        Code        = UserData.ArcID(posi(id),1);
                
        if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
        
        % Checks 
        if ~UserData.Terminal
            [ErrorMessage, Data] = CheckData(UserData, Data , Date, Code, NameCli{ar}, ProgressBar);
        else
            [ErrorMessage, Data] = CheckData(UserData, Data , Date, Code, NameCli{ar});
        end
        if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
        
        % Values Assignation
        eval(['UserData.',NameCli{ar},' = Data;'])
        
        if ~UserData.Terminal 
            waitbar(conto)
            conto = conto + 0.5;
        else
            disp(['Load ',NameCli{ar},' -> Ok'])
        end        
    end
        
    if ~UserData.Terminal 
        close(ProgressBar)
    else
        disp('Load Climate Data -> Ok')
    end    
    
catch ME    
    ErrorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);  
    
    if ~UserData.Terminal 
        close(ProgressBar)
    else
        disp(ErrorMessage)
    end
end
