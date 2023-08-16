function [ErrorMessage] = Export_TimeSeries(UserData)
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
%                              INPUT DATA 
% -------------------------------------------------------------------------
%   
%   Sce         [double]   : scenario Number
%   UserData    [Struct]   : Data Struct 
%



%% ADD VALUE TO SHAUserData.PEFILE HUA
warning off

mkdir(fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible'))
mkdir(fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Demand'))
mkdir(fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Returns'))
mkdir(fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate'))

%% Format file
CodeBasin       = UserData.ArcID;
Date            = UserData.Date;
M               = month(UserData.Date);
ResultsMMM      = NaN(length(CodeBasin),13);

%% Initial Weitbar
warning off 
ErrorMessage    = 'Successful Run';

try 
    if ~UserData.Terminal 
        ProgressBar = waitbar(0, 'Export Data MoHiTo');
    else
        disp('Export Data MoHiTo')
    end
    
    %% Streamflow
    if UserData.Inc_R_Q         == 1
        Results = reshape(UserData.VAc(:,1,:), length(CodeBasin), length(Date));

        for i = 1:12
            ResultsMMM(:,i)    = mean(Results(:,M == i),2, 'omitnan');
        end

        ResultsMMM(:,13)    = mean(Results,2, 'omitnan');

        % Save
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible','Q.csv');
        SaveCsv_Total(NameFile, CodeBasin, Results', Date)

        % Save MMM
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible','Q_MMM.csv');
        SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)    
    end 
    
    if ~UserData.Terminal
        waitbar(1/9)
    else
        disp('Export Flow -> Ok');
    end
            
    %% Runoff - Streamflow
    if UserData.Inc_R_Q         == 1
        Results = reshape(UserData.VAc(:,end,:), length(CodeBasin), length(Date));

        for i = 1:12
            ResultsMMM(:,i) = mean(Results(:,M == i),2, 'omitnan');
        end

        ResultsMMM(:,13)    = mean(Results,2, 'omitnan');

        % Save
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible','Qmm.csv');
        SaveCsv_Total(NameFile, CodeBasin, Results', Date)

        % Save MMM
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible','Qmm_MMM.csv');
        SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM) 
    end 
    
    if ~UserData.Terminal
        waitbar(2/9)
    else
        disp('Export Qmm -> Ok');
    end
    
    %% Demand or Returns
    Name    = {'Dm','R'};
    Name0   = {'Demand','Returns'};
    Name1   = {'Agri','Dom','Liv','Hy','Min'};

    for j = 1:length(Name)
        Cu      = 1;
        for k = 1:length(Name1)        
            if eval(['UserData.Inc_R_',Name1{k},'_',Name{j}])
                Results = UserData.DemandSup(:,:,Cu)';
                for i = 1:12
                    ResultsMMM(:,i)    = mean(Results(:,M == i),2,'omitnan');
                end

                ResultsMMM(:,13)    = mean(Results,2, 'omitnan');

                % Save
                NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,Name0{j},[Name1{k},'.csv']);
                SaveCsv_Total(NameFile, CodeBasin, Results', Date)

                % Save MMM
                NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,Name0{j},[Name1{k},'_MMM.csv']);
                SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)
            end 
            Cu = Cu + 1;
        end
    end

    if ~UserData.Terminal
        waitbar(3/9)
    else
        disp('Export Demand and Returns -> Ok');
    end
    
    %% Runoff
    if UserData.Inc_R_Esc   
        Results = UserData.Esc';
        for i = 1:12
            ResultsMMM(:,i)    = mean(Results(:, M == i),2,'omitnan');
        end

        ResultsMMM(:,13)    = mean(Results,2,'omitnan');

        % Save
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible','Esc.csv');
        SaveCsv_Total(NameFile, CodeBasin, Results', Date)

        % Save MMM
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible','Esc_MMM.csv');
        SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)

    end

    if ~UserData.Terminal
        waitbar(4/9)
    else
        disp('Export Runoff -> Ok');
    end
    
    %%  UserData.PreciPitation
    if UserData.Inc_R_P     

        Results = UserData.Precipitation';
        for i = 1:12
            ResultsMMM(:,i)    = mean(Results(:, M == i),2,'omitnan');
        end

        ResultsMMM(:,13)    = mean(Results,2,'omitnan');

        % Save
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate','Precipitation.csv');
        SaveCsv_Total(NameFile, CodeBasin, Results', Date)

        % Save MMM
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate','Precipitation_MMM.csv');
        SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)

    end 

    if ~UserData.Terminal
        waitbar(5/9)
    else
        disp('Export Precipitation  -> Ok');
    end
    
    %% UserData.Potential EvaPotransPiration
    if UserData.Inc_R_ETP   
        Results = UserData.Evapotranspiration';
        for i = 1:12
            ResultsMMM(:,i)    = mean(Results(:, M == i),2,'omitnan');
        end

        ResultsMMM(:,13)    = mean(Results,2,'omitnan');

        % Save
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate','Potantial_Evapotranspiration.csv');
        SaveCsv_Total(NameFile, CodeBasin, Results', Date)

        % Save MMM
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate','Potential_Evapotranspiration_MMM.csv');
        SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)
    end 

    if ~UserData.Terminal
        waitbar(6/9)
    else
        disp('Export Potential Evapotranspiration -> Ok');
    end
    
    %% Actual EvaUserData.PotransUserData.Piration
    if UserData.Inc_R_ETR  
        Results = UserData.ETR';
        for i = 1:12
            ResultsMMM(:,i)    = mean(Results(:, M == i),2,'omitnan');
        end

        ResultsMMM(:,13)    = mean(Results,2,'omitnan');

        % Save
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate','Actual_Evapotranspiration.csv');
        SaveCsv_Total(NameFile, CodeBasin, Results', Date)

        % Save MMM
        NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'Climate','Actual_Evapotranspiration_MMM.csv');
        SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM) 
    end 

    if ~UserData.Terminal
        waitbar(7/9)
    else
        disp('Export Actual Evapotranspiration -> Ok');
    end
    
    %% States Variables Thomas Model
    Name = {'Sw','Sg','Y','Ro','Rg','Qg'};
    for j = 1:length(Name)
        if eval(['UserData.Inc_R_',Name{j}])
            Results = UserData.StatesMT(:,:,j)';

            for i = 1:12
                ResultsMMM(:,i)    = mean(Results(:,M == i),2,'omitnan');
            end

            ResultsMMM(:,13)    = mean(Results,2, 'omitnan');

            % Save
            NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible',[Name{j},'.csv']);
            SaveCsv_Total(NameFile, CodeBasin, Results', Date)

            % Save MMM
            NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible',[Name{j},'_MMM.csv']);
            SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)
        end
    end

    if ~UserData.Terminal
        waitbar(8/9)
    else
        disp('Export States Varibles - ABCD -> Ok');
    end
    
    %% States Variables FloodUserData.Plains Model
    Name = {'Vh','Ql','Rl'};
    for j = 1:length(Name)
        if eval(['UserData.Inc_R_',Name{j}]) 
            Results = UserData.StatesMF(:,:,1)';

            for i = 1:12
                ResultsMMM(:,i)    = mean(Results(:,M == i),2,'omitnan');
            end

            ResultsMMM(:,13)    = mean(Results,2, 'omitnan');

            % Save
            NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible',[Name{j},'.csv']);
            SaveCsv_Total(NameFile, CodeBasin, Results', Date)

            % Save MMM
            NameFile    = fullfile(UserData.PathProject,'OUTPUTS',UserData.Scenarios,'StatesVarible',[Name{j},'_MMM.csv']);
            SaveCsv_MMM(NameFile, CodeBasin, ResultsMMM)

        end
    end
    
    if ~UserData.Terminal
        waitbar(9/9)
        disp('Export States Varibles - floodplaning -> Ok');
        close(ProgressBar)
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