function [ErrorMessage, UserData] = Load_Model(UserData)
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

    if ~UserData.Terminal 
        ProgressBar = waitbar(0, 'Load Data -> Parameters.MoHiTo');
        wbch        = allchild(ProgressBar);
        jp          = wbch(1).JavaPeer;
        jp.setIndeterminate(1)
    else
        disp('Load Data -> Parameters.MoHiTo')
    end
    
    %% -------------------------------------------------------------------------
    % Parameter  Model
    % -------------------------------------------------------------------------
    try
        Tmp       = dlmread( fullfile(UserData.PathProject,'Parameters.MoHiTo') ,',',1,0);
        [~, Poo]  = sort(Tmp(:,1));    
        Tmp       = Tmp(Poo,:);
    catch
        ErrorMessage    = 'The Parameters.MoHiTo not found';
        if ~UserData.Terminal 
            close(ProgressBar)
            errordlg(ErrorMessage,'!! Error !!')
        end
        return
    end    
    
    % Values Assignation 
    UserData.ArcID          = Tmp(:,1);
    UserData.Arc_InitNode   = Tmp(:,2);
    UserData.Arc_EndNode    = Tmp(:,3);
    UserData.BasinArea      = Tmp(:,4);
    UserData.FloodArea      = Tmp(:,4).*Tmp(:,5); % Perc to m2
    UserData.TypeBasinCal   = Tmp(:,6);               
    UserData.IDAq           = Tmp(:,9);    
    UserData.Sw             = Tmp(:,10);
    UserData.Sg             = Tmp(:,11);
    UserData.Vh             = Tmp(:,12);
    UserData.a              = Tmp(:,13);
    UserData.b              = Tmp(:,14);
    UserData.c              = Tmp(:,15);
    UserData.d              = Tmp(:,16);
    UserData.ParamExtSup    = Tmp(:,17);
    UserData.Trp            = Tmp(:,18);
    UserData.Tpr            = Tmp(:,19);
    UserData.Q_Umb          = Tmp(:,20);
    UserData.V_Umb          = Tmp(:,21);
    UserData.IDExtAgri      = Tmp(:,22);
    UserData.IDExtDom       = Tmp(:,23);
    UserData.IDExtLiv       = Tmp(:,24); 
    UserData.IDExtHy        = Tmp(:,25); 
    UserData.IDExtMin       = Tmp(:,26);
    UserData.IDRetAgri      = Tmp(:,27);
    UserData.IDRetDom       = Tmp(:,28);
    UserData.IDRetLiv       = Tmp(:,29);
    UserData.IDRetHy        = Tmp(:,30);
    UserData.IDRetMin       = Tmp(:,31);    
    UserData.ArcID_Downstream       = UserData.ArcID(logical(Tmp(:,7)));
    UserData.Interest_Points_Code   = UserData.ArcID(logical(Tmp(:,8)));
    
    if ~UserData.Terminal 
        close(ProgressBar)
    else
        disp('Load Data -> Parameters.MoHiTo -> Ok')
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
        