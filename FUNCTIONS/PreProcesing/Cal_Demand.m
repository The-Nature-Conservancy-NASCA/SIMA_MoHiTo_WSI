function [ErrorMessage, UserData] = Cal_Demand(UserData)
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

%% Initial Waitbar
warning off 
ErrorMessage    = 'Successful Run';

% Demand Type
DemandVar       = {'Agricultural','Domestic','Livestock','Hydrocarbons','Mining'};
SimDemandVar    = {'Agri','Dom','Liv','Hy','Min'};
try
    % Progres Process
    % --------------
    if ~UserData.Terminal 
        ProgressBar = waitbar(0, 'Demand Estimation');
        wbch        = allchild(ProgressBar);
        jp          = wbch(1).JavaPeer;
        jp.setIndeterminate(1)
    else
        disp('Demand Estimation')
    end
    
    for i = 1:length(DemandVar)
        
        if UserData.Terminal 
            disp(['Estimation -> ', DemandVar{i},' Demand'])
            disp('-----------------------------')
        end
        
        NameFileDemand = eval(['UserData.',DemandVar{i}]);
        if isempty(NameFileDemand)
            continue
        end
        
        % Module
        mkdir(fullfile(UserData.PathProject,'INPUTS', UserData.Scenarios, 'Demand', DemandVar{i}))

        % Value
        mkdir(fullfile(UserData.PathProject,'INPUTS', UserData.Scenarios, 'Returns',DemandVar{i}))
            
        for Nexc = 1:length(NameFileDemand)
            
            if UserData.Terminal 
                disp(['Estimation -> ', NameFileDemand{Nexc}])
            end
            
            NameFileCsv = fullfile(UserData.PathProject,'PREPROCESSING',UserData.Scenarios,...
                    'Demand',DemandVar{i},'Value');
                
            NameFileCsv1 = fullfile(UserData.PathProject,'PREPROCESSING',UserData.Scenarios,...
                    'Demand',DemandVar{i},'Module');

            if strcmp(DemandVar{i},'Agricultural')
                eval('DemandData.TypeCrop      = UserData.TypeCrop{Nexc};');
                eval('DemandData.TimeCrop      = UserData.TimeCrop(Nexc);');
                eval(['DemandData.Loss         = UserData.PorLoss',SimDemandVar{i},'(Nexc);']);
                eval(['DemandData.PorReturns   = UserData.PorReturn',SimDemandVar{i},'(Nexc);']);
                
                [ErrorMessage, DataV, DemandData.Date, DemandData.CodeBasin] = ...
                    Load_Data(fullfile(NameFileCsv, [NameFileDemand{Nexc},'.csv']), NameFileDemand{Nexc});
                
                [id, posi]              = ismember(DemandData.CodeBasin, UserData.ArcID);
                DataV                   = DataV(:,posi(id));
                DemandData.CodeBasin    = UserData.ArcID(posi(id),1);
                
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
                    
                [ErrorMessage, DataM, ~, CodeBasinM] = Load_Data(fullfile(NameFileCsv1, [NameFileDemand{Nexc},'.csv']), NameFileDemand{Nexc});
                
                [~, posi]               = ismember(CodeBasinM, UserData.ArcID);
                DataM                   = DataM(:,posi);
                
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
            else                
                eval(['DemandData.Loss          = UserData.PorLoss',SimDemandVar{i},'(Nexc);']);
                eval(['DemandData.PorReturns    = UserData.PorReturn',SimDemandVar{i},'(Nexc);']);
                
                [ErrorMessage, DataV, DemandData.Date, DemandData.CodeBasin] = ...
                    Load_Data(fullfile(NameFileCsv, [NameFileDemand{Nexc},'.csv']), NameFileDemand{Nexc});
                
                [id, posi]              = ismember(DemandData.CodeBasin, UserData.ArcID);
                DataV                   = DataV(:,posi);
                DemandData.CodeBasin    = UserData.ArcID(posi(id),1);
                
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end
                    
                [ErrorMessage, DataM, ~, CodeBasinM] = Load_Data(fullfile(NameFileCsv1, [NameFileDemand{Nexc},'.csv']), NameFileDemand{Nexc});
                
                [~, posi]               = ismember(CodeBasinM, UserData.ArcID);
                DataM                   = DataM(:,posi);
                
                if ~strcmp(ErrorMessage,'Successful Run'), if ~UserData.Terminal, close(ProgressBar),end, return, end            
            end

            %% Calculate Demand
            % !!! Demand in Cubic Meters (m3) !!!
            % 1) => Agricultural    
            % 2) => Domestic
            % 3) => Livestock
            % 4) => Hydrocarbons
            % 5) => Mining

            DayMonths   = [31 28 31 30 31 30 31 31 30 31 30 31];
            nm          = length(DemandData.Date);
            nn          = month(DemandData.Date(1));

            if strcmp(DemandVar{i},'Agricultural')

                % Area in Hec to Squart Meter
                FactorArea = 10000;

                if strcmp(DemandData.TypeCrop, 'Trasients')                           
                    DataVV = DataV';
                    DataV  = DataV';
                    DataVV(:,1:DemandData.TimeCrop) = cumsum(DataV(:,1:DemandData.TimeCrop), 2, 'omitnan');
                    for r = (DemandData.TimeCrop + 1):length(DataV(1,:))                            
                        DataVV(:,r) = sum(DataV(:,(r-DemandData.TimeCrop+1):r), 2, 'omitnan');
                    end
                    % Area in m2
                    DataV = DataVV' * FactorArea;
                else

                    % Area in m2
                    DataV  = DataV * FactorArea;
                end

                BalanceH = ((UserData.Evapotranspiration.* DataM) - UserData.Precipitation);
                BalanceH(BalanceH<0) = 0;

                % Estimation Agricultural Demand                        
                ValuesDemand = (DataV .* (BalanceH./1000))/(1 - DemandData.Loss);

            elseif strcmp(DemandVar{i},'Domestic')
                % !!! Demand in Cubic Meters (m^3) !!!
                % Liters to Cubic Meter
                DataV           = DataV';
                DataM           = DataM';
                Factor_lts_M3   = (1/1000);
                Tmp             = repmat(DayMonths,length(DemandData.CodeBasin),length(unique(year(DemandData.Date))));
                ValuesDemand    = (Factor_lts_M3 .* DataV .* DataM .* Tmp(:,nn:(nm + nn - 1)))'./(1 - DemandData.Loss);

            elseif strcmp(DemandVar{i},'Livestock') || strcmp(DemandVar{i},'Hydrocarbons')
                % !!! Demand in Cubic Meters (m^3) !!!
                 % Liters to Cubic Meter
                DataV           = DataV';
                DataM           = DataM';
                Factor_lts_M3   = (1/1000);
                Tmp             = repmat(DayMonths,length(DemandData.CodeBasin),length(unique(year(DemandData.Date))));
                ValuesDemand    = (Factor_lts_M3 .* DataV .* DataM .* Tmp(:,nn:(nm + nn - 1)))'./(1 - DemandData.Loss);

            elseif strcmp(DemandVar{i},'Mining')
                % !!! Demand in Cubic Meters (m^3) !!!
                ValuesDemand   = (DataV .* DataM)./(1 - DemandData.Loss);

            end

            %% Save Demands
            NameFileCsv = fullfile( UserData.PathProject,'INPUTS', UserData.Scenarios, 'Demand',...
                DemandVar{i},[NameFileDemand{Nexc},'.csv']);

            SaveCsv_Total(NameFileCsv, DemandData.CodeBasin, ValuesDemand, DemandData.Date);

            %% Save Returns
            NameFileCsv = fullfile(  UserData.PathProject,'INPUTS', UserData.Scenarios,'Returns',...
                                    DemandVar{i},[NameFileDemand{Nexc},'.csv']);

            SaveCsv_Total(NameFileCsv, DemandData.CodeBasin, ValuesDemand.*DemandData.PorReturns, DemandData.Date);
            
            if UserData.Terminal 
                disp(['Estimation -> ', NameFileDemand{Nexc},' -> Ok'])
            end
            
        end

    end       
    
    if ~UserData.Terminal 
        close(ProgressBar)
    else
        disp('Demand Estimation -> Ok')
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
