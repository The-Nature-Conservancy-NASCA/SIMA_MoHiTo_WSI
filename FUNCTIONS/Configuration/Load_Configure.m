function [ErrorMessage, UserData] = Load_Configure(PathProject)
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

UserData.PathProject        = PathProject;
UserData.ModeModel          = 1;
UserData.Parallel           = false;
UserData.Terminal           = true;
UserData.CoresNumber        = 4;
UserData.Scenarios          = {};
UserData.NumberSceCal       = 1; 
UserData.RangeParamsSCE     = [];
UserData.RangeParamsModel   = [];
UserData.Agricultural       = {};
UserData.Domestic           = {};
UserData.Livestock          = {};
UserData.Hydrocarbons       = {};
UserData.Mining             = {};
UserData.Groundwater        = {};
UserData.Inc_R_Q            = true;
UserData.Inc_R_P            = true;
UserData.Inc_R_Esc          = true;
UserData.Inc_R_ETP          = true;
UserData.Inc_R_ETR          = true;
UserData.Inc_R_Sw           = true;
UserData.Inc_R_Sg           = true;
UserData.Inc_R_Y            = true;
UserData.Inc_R_Ro           = true;
UserData.Inc_R_Rg           = true;
UserData.Inc_R_Qg           = true;
UserData.Inc_R_Ql           = true;
UserData.Inc_R_Rl           = true;
UserData.Inc_R_Vh           = true;
UserData.Inc_R_Agri_Dm      = true;
UserData.Inc_R_Dom_Dm       = true;
UserData.Inc_R_Liv_Dm       = true;
UserData.Inc_R_Hy_Dm        = true;
UserData.Inc_R_Min_Dm       = true;
UserData.Inc_R_Agri_R       = true;
UserData.Inc_R_Dom_R        = true;
UserData.Inc_R_Liv_R        = true;
UserData.Inc_R_Hy_R         = true;
UserData.Inc_R_Min_R        = true;
UserData.Inc_R_Index        = true;
UserData.Inc_R_TS           = true;
UserData.Inc_R_Box          = true;
UserData.Inc_R_Fur          = true;
UserData.Inc_R_DC           = true;
UserData.Inc_R_MMM          = true;
UserData.TypeCrop           = cell(1,200);
UserData.TimeCrop           = NaN(1,200);
UserData.PorLossAgri        = NaN(1,200);
UserData.PorReturnAgri      = NaN(1,200);
UserData.PorLossDom         = NaN(1,200);
UserData.PorReturnDom       = NaN(1,200);
UserData.PorLossLiv         = NaN(1,200);
UserData.PorReturnLiv       = NaN(1,200);
UserData.PorLossHy          = NaN(1,200);
UserData.PorReturnHy        = NaN(1,200);
UserData.PorLossMin         = NaN(1,200);
UserData.PorReturnMin       = NaN(1,200);
UserData.CalDemand          = true;
UserData.Date               = datetime();

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
    
    %% Open File   
    ID_File = fopen(fullfile(PathProject,'Configure.MoHiTo'),'r');
    
    % Check Configure.MoHiTo File
    if ID_File == -1
        ErrorMessage    = 'The Configure.MoHiTo not found';
        if ~UserData.Terminal 
            close(ProgressBar)
            errordlg(ErrorMessage,'!! Error !!')
        end
        return
    end
    
    Jo = 0;
    Po1 = 1;
    LineFile = fgetl(ID_File);
    while ischar(LineFile)        
        if contains( LineFile, '*')
            LineFile = strrep(LineFile,'*','');
            LineFile = strrep(LineFile,' ','');
            LineFile = strsplit(LineFile,'>');
            Po = str2double(LineFile{1});
            if Po == Po1
                Jo = Jo + 1;
            else
                Jo = 1;
            end
            Tmp = strsplit(LineFile{2},'|');
            if Po == 1
                UserData.ModeModel          = str2double(LineFile{2});
            elseif Po == 2
                UserData.Parallel           = logical(str2double(Tmp{1}));
                UserData.CoresNumber        = str2double(Tmp{2});
            elseif Po == 3
                UserData.Terminal           = logical(str2double(LineFile{2}));                
            elseif Po == 4            
                UserData.Scenarios          = Tmp(:);                
            elseif Po == 5
                UserData.SceCal             = LineFile{2};
            elseif Po == 6            
                UserData.RangeParamsSCE     = (cellfun(@str2double,strsplit(LineFile{2},'|')));
            elseif Po == 7
                Tmp = strsplit(LineFile{2},'|');
                for i = 1:length(Tmp)
                    UserData.RangeParamsModel(i,:)   = (cellfun(@str2double,strsplit(Tmp{i},','))); 
                end
            elseif Po == 8
                ParDe = strsplit(LineFile{2},'|');
                UserData.TypeCrop{Jo}       = ParDe{1};
                UserData.TimeCrop(Jo)       = str2double(ParDe{2});
                UserData.PorLossAgri(Jo)    = str2double(ParDe{3});
                UserData.PorReturnAgri(Jo)  = str2double(ParDe{4});
                UserData.Agricultural{Jo}   = ParDe{5};                
            elseif Po == 9
                ParDe = strsplit(LineFile{2},'|');
                UserData.PorLossDom(Jo)     = str2double(ParDe{1});
                UserData.PorReturnDom(Jo)   = str2double(ParDe{2});
                UserData.Domestic{Jo}       = ParDe{3};
            elseif Po == 10
                ParDe = strsplit(LineFile{2},'|');
                UserData.PorLossLiv(Jo)     = str2double(ParDe{1});
                UserData.PorReturnLiv(Jo)   = str2double(ParDe{2});
                UserData.Livestock{Jo}      = ParDe{3};
            elseif Po == 11
                ParDe = strsplit(LineFile{2},'|');
                UserData.PorLossHy(Jo)      = str2double(ParDe{1});
                UserData.PorReturnHy(Jo)    = str2double(ParDe{2});
                UserData.Hydrocarbons{Jo}   = ParDe{3};
            elseif Po == 12
                ParDe = strsplit(LineFile{2},'|');
                UserData.PorLossMin(Jo)     = str2double(ParDe{1});
                UserData.PorReturnMin(Jo)   = str2double(ParDe{2});
                UserData.Mining{Jo}         = ParDe{3};
            elseif Po == 13
                UserData.Groundwater{Jo}    = LineFile{2};
            elseif Po == 14
                UserData.Inc_R_Q        = logical(str2double(Tmp{2}));
            elseif Po == 15
                UserData.Inc_R_P        = logical(str2double(Tmp{2}));
            elseif Po == 16
                UserData.Inc_R_Esc      = logical(str2double(Tmp{2}));
            elseif Po == 17
                UserData.Inc_R_ETP      = logical(str2double(Tmp{2}));
            elseif Po == 18
                UserData.Inc_R_ETR      = logical(str2double(Tmp{2}));
            elseif Po == 19
                UserData.Inc_R_Sw       = logical(str2double(Tmp{2}));
            elseif Po == 20
                UserData.Inc_R_Sg       = logical(str2double(Tmp{2}));
            elseif Po == 21
                UserData.Inc_R_Y        = logical(str2double(Tmp{2}));
            elseif Po == 22
                UserData.Inc_R_Ro       = logical(str2double(Tmp{2}));
            elseif Po == 23
                UserData.Inc_R_Rg       = logical(str2double(Tmp{2}));
            elseif Po == 24
                UserData.Inc_R_Qg       = logical(str2double(Tmp{2}));
            elseif Po == 25
                UserData.Inc_R_Ql       = logical(str2double(Tmp{2}));
            elseif Po == 26
                UserData.Inc_R_Rl       = logical(str2double(Tmp{2}));
            elseif Po == 27            
                UserData.Inc_R_Vh       = logical(str2double(Tmp{2}));
            elseif Po == 28
                UserData.Inc_R_Agri_Dm  = logical(str2double(Tmp{2}));
            elseif Po == 29
                UserData.Inc_R_Dom_Dm   = logical(str2double(Tmp{2}));
            elseif Po == 30
                UserData.Inc_R_Liv_Dm   = logical(str2double(Tmp{2}));
            elseif Po == 31
                UserData.Inc_R_Hy_Dm    = logical(str2double(Tmp{2}));
            elseif Po == 32
                UserData.Inc_R_Min_Dm   = logical(str2double(Tmp{2}));
            elseif Po == 33
                UserData.Inc_R_Agri_R   = logical(str2double(Tmp{2}));
            elseif Po == 34
                UserData.Inc_R_Dom_R    = logical(str2double(Tmp{2}));
            elseif Po == 35
                UserData.Inc_R_Liv_R    = logical(str2double(Tmp{2}));
            elseif Po == 36
                UserData.Inc_R_Hy_R     = logical(str2double(Tmp{2}));
            elseif Po == 37
                UserData.Inc_R_Min_R    = logical(str2double(Tmp{2}));
            elseif Po == 38
                UserData.Inc_R_Index    = logical(str2double(Tmp{2}));
            elseif Po == 39
                UserData.Inc_R_TS       = logical(str2double(Tmp{2}));
            elseif Po == 40
                UserData.Inc_R_Box      = logical(str2double(Tmp{2}));
            elseif Po == 41
                UserData.Inc_R_Fur      = logical(str2double(Tmp{2}));
            elseif Po == 42
                UserData.Inc_R_DC       = logical(str2double(Tmp{2}));
            elseif Po == 43
                UserData.Inc_R_MMM      = logical(str2double(Tmp{2}));
            elseif Po == 44
                UserData.CalDemand      = logical(str2double(LineFile{2})); 
            end
            Po1 = Po;
        end
        LineFile = fgetl(ID_File);
    end
    fclose(ID_File);
    
    %% Parameters Configuration
    DateInit        = UserData.Scenarios{2};
    DateEnd         = UserData.Scenarios{3};
    Date1           = datetime(['01-',DateInit],'InputFormat','dd-MM-yyyy');
    Date2           = datetime(['01-',DateEnd],'InputFormat','dd-MM-yyyy');
    UserData.Date   = (Date1:calmonths:Date2)';
    
    %% Scenario
    UserData.Scenarios = UserData.Scenarios{1};
    
    if ~UserData.Terminal 
        close(ProgressBar)
    else
        disp('Load Data -> Parameters.MoHiTo -> Ok')
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