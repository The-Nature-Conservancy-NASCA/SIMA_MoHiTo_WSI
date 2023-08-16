function [Qsim, ETR, States] = Thomas_fix(P, ETP, a, b, c, d, kc, Sw, Sg,A)
% /usr/bin/Matlab-R2016b
% -------------------------------------------------------------------------
% Model Of Thomas - (1981) - "abcd"
%
% -------------------------------------------------------------------------
% BASE DATA
% -------------------------------------------------------------------------
% Project               : Landscape planning for agro-industrial expansion 
%                         in a large, well-preserved savanna: how to plan 
%                         multifunctional landscapes at scale for nature and 
%                         people in the Orinoquia region, Colombia
% Author                : Jonathan Nogales Pimentel
% Email                 : nogales02@hotmail.com
% Supervisor            : Carlos Andrés Rogéliz
% Company               : The Nature Conservancy - TNC
% 
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program.  
% If not, see http://www.gnu.org/licenses/.
%
% -------------------------------------------------------------------------
% INPUT DATA 
% -------------------------------------------------------------------------
%   P       [Cat,1] = Precipitation                     [mm]
%   ETP     [Cat,1] = Potential Evapotranspiration      [mm]
%   a       [Cat,1] = Soil Retention Capacity           [Ad]
%   b       [Cat,1] = Maximum Capacity of Soil Storage  [Ad]
%   c       [Cat,1] = Flow Fraction Soil - Aquifer      [Ad]
%   d       [Cat,1] = Flow Fraction Aquifer - Soil      [Ad]
%   Sw      [Cat,1] = Soil Moisture                     [mm]
%   Sg      [Cat,1] = Aquifer Storage                   [mm]
%   Sg      [Cat,1] = Catchment area                    [km2]
%   kc      [Cat,1] = crop coefficient                  [Ad]
% -------------------------------------------------------------------------
% OUTPUT DATA
% -------------------------------------------------------------------------
%   Qsim    [Cat,1] = Runoff Simulated                  [mm]
%   ETR     [Cat,1] = Actual Evapotranspiration         [mm]
%   States  [Cat,1] = States Variables                  [mm]
%

%% THOMAS HYDROLOGICAL MODEL 
% Available Soil Water
W       = P + Sw;
% Evapotranspiration Potential
Y       = ((W + b) ./ (2 * a)) - sqrt((((W + b) ./ (2 * a)).^2) - ((W .* b) ./ a));
% Actual Evapotrasnpiration
ETR     = (1/sum(A))*(sum(ETP.*kc.*A,2));
% Soil Moisture 
Sw      = Y-ETR; % cambiar exp por kc*ET0; Sw=Y-kc*ET0
%Y       = ETR+Sw;
Sw(Sw<0)=0;
% Direct Runoff
Ro      = (1 - c) .* (W - Y);
% Aquifer reload
Rg      = c .* (W - Y); 
% Groundwater Storage
Sg      = (Rg + Sg) ./ (1 + d);
% Groundwater Discharge
Qg      = d .* Sg;
% Runoff Simulated 
Qsim    = Ro + Qg;

% States Variables
States  = [W, Sw, Sg, Y, Ro, Rg, Qg ];