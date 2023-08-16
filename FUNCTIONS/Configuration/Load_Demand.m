function [ErrorMessage, UserData] = Load_Demand(UserData)
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
% UserData [Struct]
%   .ArcID               [Cat,1]         = ID of each section of the network                     [Ad]
%   .Arc_InitNode        [Cat,1]         = Initial node of each section of the network           [Ad]
%   .Arc_EndNode         [Cat,1]         = End node of each section of the network               [Ad]
%   .ArcID_Downstream    [1,1]           = ID of the end node of accumulation                    [Ad]
%   .AccumVar            [Cat,Var]       = Variable to accumulate                                
%   .AccumStatus         [Cat,Var]       = Status of the accumulation variable == AccumVar       
%   .ArcIDFlood          [CatFlood,1]    = ID of the section of the network with floodplain      [Ad]
%   .FloodArea           [CatFlood,1]    = Floodplain Area                                       [m^2]
%   .IDExtAgri           [Cat,1]         = ID of the HUA where to extraction Agricultural Demand [Ad]
%   .IDExtDom            [Cat,1]         = ID of the HUA where to extraction Domestic Demand     [Ad]
%   .IDExtLiv            [Cat,1]         = ID of the HUA where to extraction Livestock Demand    [Ad]
%   .IDExtMin            [Cat,1]         = ID of the HUA where to extraction Mining Demand       [Ad]
%   .IDExtHy             [Cat,1]         = ID of the HUA where to extraction Hydrocarbons Demand [Ad]
%   .IDRetDom            [Cat,1]         = ID of the HUA where to return Domestic Demand         [Ad]
%   .IDRetLiv            [Cat,1]         = ID of the HUA where to return Livestock Demand        [Ad]
%   .IDRetMin            [Cat,1]         = ID of the HUA where to return Mining Demand           [Ad]
%   .IDRetHy             [Cat,1]         = ID of the HUA where to return Hydrocarbons Demand     [Ad]
%   .P                   [Cat,1]         = Precipitation                                         [mm]
%   .ETP                 [Cat,1]         = Actual Evapotrasnpiration                             [mm]
%   .Vh                  [CatFlood,1]    = Volume of the floodplain Initial                      [mm]
%   .Ql                  [CatFlood,1]    = Lateral flow between river and floodplain             [mm]
%   .Rl                  [CatFlood,1]    = Return flow from floodplain to river                  [mm]
%   .Trp                 [CatFlood,1]    = Percentage lateral flow between river and floodplain  [dimensionless]
%   .Tpr                 [CatFlood,1]    = Percentage return flow from floodplain to river       [dimensionless]
%   .Q_Umb               [CatFlood,1]    = Threshold lateral flow between river and floodplain   [mm]
%   .V_Umb               [CatFlood,1]    = Threshold return flow from floodplain to river        [mm]
%   .a                   [Cat,1]         = Soil Retention Capacity                               [dimensionless]
%   .b                   [Cat,1]         = Maximum Capacity of Soil Storage                      [dimensionless]
%   .Y                   [Cat,1]         = Evapotranspiration Potential                          [mm]
%   .PoPo                [Cat,1]         = ID of the HUA to calibrate                            [Ad]
%   .PoPoFlood           [Cat,1]         = ID of the HUA to calibrate with floodplains           [Ad]
%   .ArcID_Downstream2   [1,1]           = ID of the end node of accumulation                    [Ad]
%

%% Initial Weitbar
warning off 

ErrorMessage    = 'Successful Run';
try
    %% -------------------------------------------------------------------------
    %  TOTAL SURFACE DEMAND 
    % -------------------------------------------------------------------------
    if ~UserData.Terminal
        ProgressBar     = waitbar(0, 'Load Demand and Return Data  ...');
    else
        disp('Load Demand and Return Data  ...')
    end
    
    DemandVar  = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};
    UserData.DemandSup  = zeros(length(UserData.Date), length(UserData.ArcID),length(DemandVar));
    UserData.Returns    = zeros(length(UserData.Date), length(UserData.ArcID),length(DemandVar));

    NameDm  = {'UserData.DemandSup', 'UserData.Returns'};
    DeRe    = {'Demand','Returns'};
    for dr = 1:length(DeRe)
        for VarD = 1:length(DemandVar)            
            NameFileDemand = eval(['UserData.',DemandVar{VarD}]);
            if isempty(NameFileDemand)
                continue
            end
            for i = 1:length(NameFileDemand)                
                NameFile = fullfile(UserData.PathProject,'INPUTS',UserData.Scenarios,...
                    DeRe{dr},DemandVar{VarD},[NameFileDemand{i},'.csv']);

                % Load Data
                [ErrorMessage, Data, Date, Code] = Load_Data(NameFile, [DeRe{dr},' ',NameFileDemand{i}]);
                
                [id, posi]  = ismember(Code, UserData.ArcID);
                Data        = Data(:,posi(id));
                Code        = UserData.ArcID(posi(id));
                
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end

                % Checks 
                if ~UserData.Terminal
                    [ErrorMessage, Data] = CheckData(UserData, Data , Date, Code, [DeRe{dr},' ',NameFileDemand{i}], ProgressBar);
                else
                    [ErrorMessage, Data] = CheckData(UserData, Data , Date, Code, [DeRe{dr},' ',NameFileDemand{i}]);
                end
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
                
                if i == 1
                    Data_i = Data;
                else
                    Data_i = Data_i + Data;
                end
                
                if UserData.Terminal
                    disp(['Load -> ', DeRe{dr},' - ', NameFileDemand{i},' Demand -> Ok'])
                end
            end
            
            % Values Assignation
            eval([NameDm{dr},'(:,:,',num2str(VarD),') = Data_i;']);
            
            if ~UserData.Terminal
                waitbar((VarD*dr)/(length(DemandVar)*2))
            else
                disp(['Load -> ',DemandVar{VarD},' Demand -> Ok'])
            end
        end
    end    
    
    if ~UserData.Terminal 
        waitbar(1)
        close(ProgressBar)
    else
        disp('Load Demand and Return Data -> Ok')
    end
    
    
    %% -------------------------------------------------------------------------
    % TOTAL UNDERGROUND DEMANDA
    % -------------------------------------------------------------------------        
    if ~UserData.Terminal
        ProgressBar     = waitbar(0, 'Load Groundwater Demand Data  ...');
    else
        disp('Load Groundwater Demand Data  ...')
    end
    
    DemandVar  = {'Groundwater'};
    UserData.DemandSub  = zeros(length(UserData.Date), length(UserData.ArcID));

    NameDm  = {'UserData.DemandSub'};
    DeRe    = {'Demand'};
    for dr = 1:length(DeRe)
        for VarD = 1:length(DemandVar)            
            NameFileDemand = eval(['UserData.',DemandVar{VarD}]);
            if isempty(NameFileDemand)
                continue
            end
            for i = 1:length(NameFileDemand)                
                NameFile = fullfile(UserData.PathProject,'INPUTS',UserData.Scenarios,...
                    DeRe{dr},DemandVar{VarD},[NameFileDemand{i},'.csv']);

                % Load Data
                [ErrorMessage, Data, Date, Code] = Load_Data(NameFile, NameFileDemand{i});
                
                [id, posi]  = ismember(Code, UserData.ArcID);
                Data        = Data(:,posi(id));
                Code        = UserData.ArcID(posi(id),1);
                
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end

                % Checks 
                if ~UserData.Terminal
                    [ErrorMessage, Data] = CheckData(UserData, Data , Date, Code, NameFileDemand{i}, ProgressBar);
                else
                    [ErrorMessage, Data] = CheckData(UserData, Data , Date, Code, NameFileDemand{i});
                end
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
                
                if i == 1
                    Data_i = Data;
                else
                    Data_i = Data_i + Data;
                end
            end
            
            % Values Assignation
            eval([NameDm{dr},'(:,:) = Data_i;']);
            
        end
    end    
    
    if ~UserData.Terminal 
        waitbar(1)
        close(ProgressBar)
    else
        disp('Load Groundwater Demand Data -> OK')
    end
    
    if ~UserData.Terminal 
        [Icon,~] = imread('Completed.jpg'); 
        msgbox('load of demand data complected','Success','custom',Icon);
    end
    
catch ME    
    ErrorMessage    = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    
    if ~UserData.Terminal 
        close(ProgressBar)
    else
        disp(ErrorMessage)
    end
end
        