% -------------------------------------------------------------------------
% Matlab Version - R2019b 
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
%               Carlos Andrés Rogéliz 
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

%% Preliminary
clear
clc
close
warning off

addpath(genpath('C:\Users\l.albornoz\Box\GGIRH-Projects\0002_AIF-Orinoquia\02-Tecnico\03-InfoBase\03-MoHiTo\CODES\MoHiTo_SIMA'))

%% Inputs Data
FileControlMATLAB   = 'Control_File_MATLAB.MoHiTo';
try 
    %% Load Control File MATLAB        
    try
        ID_File     = fopen(FileControlMATLAB ,'r');

        LineFile = fgetl(ID_File);
        while ischar(LineFile)

            Tmp = strfind(LineFile, '*');
            if ~isempty(Tmp)                
                LineFile = strrep(LineFile,'*','');
%                 LineFile = strrep(LineFile,' ','');
                PathProject  = LineFile;                
            end
            LineFile = fgetl(ID_File);
        end
        fclose(ID_File);
    catch 
        fclose(ID_File);
        ErrorMessage    = 'The Control_File_MATLAB.MoHiTo not found';
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
        
    end    
    disp(['Step-1|Ok|','-> Load Control File Matlab'])
    
    PathProject = 'C:\Users\l.albornoz\Box\GGIRH-Projects\0002_AIF-Orinoquia\02-Tecnico\03-InfoBase\03-MoHiTo\Config_SIMA';
    
    %% Remove ErrorFile 
    NameFile = fullfile(PathProject, 'Error.MoHiTo');
    delete(NameFile);
    
    tic
    %% Load Configuration Data - MoHiTo
    [ErrorMessage, UserData] = Load_Configure(PathProject);
    if ~strcmp(ErrorMessage,'Successful Run')
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
    end
    
    disp(['Step-2|Ok|','-> Load Configure.MoHiTo File'])
    
    %% Load Model Parameters - MoHiTo
    [ErrorMessage, UserData] = Load_Model(UserData);
    if ~strcmp(ErrorMessage,'Successful Run')
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
    end
    
    disp(['Step-3|Ok|','-> Load Parameters.MoHiTo File'])

    %% Load Climate Data - MoHiTo
    [ErrorMessage, UserData] = Load_Climate(UserData);
    if ~strcmp(ErrorMessage,'Successful Run')
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
    end
    
    disp(['Step-4|Ok|','-> Load Climate Data'])
    
    if UserData.CalDemand
        %% Demand Estimation - MoHiTo
        [ErrorMessage, UserData] = Cal_Demand(UserData);
        if ~strcmp(ErrorMessage,'Successful Run')
            NameFile = fullfile(PathProject, 'Error.MoHiTo');
            WriteError(NameFile, ErrorMessage)
            return
        end
    end
     
    %% Load Demand Data - MoHiTo
    [ErrorMessage, UserData] = Load_Demand(UserData);
    if ~strcmp(ErrorMessage,'Successful Run')
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
    end

    %% Run MoHiTo
    [ErrorMessage, UserData] = RunModel(UserData);
    if ~strcmp(ErrorMessage,'Successful Run')
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
    end

    %% Export Data 
    [ErrorMessage] = Export_TimeSeries(UserData);
    if ~strcmp(ErrorMessage,'Successful Run')
        NameFile = fullfile(PathProject, 'Error.MoHiTo');
        WriteError(NameFile, ErrorMessage)
        return
    end
    
    %% Time
    t = toc;
    disp(['Execution Time - MoHiTo = ', num2str(t/60,'%0.2f'),' Min'])
    WriteError(NameFile, ErrorMessage)
    
catch ME
    ErrorMessage    = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);  
    
    NameFile = fullfile(PathProject, 'Error.MoHiTo');
    WriteError(NameFile, ErrorMessage)
end
