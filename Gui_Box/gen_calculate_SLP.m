function [ SLP ] = gen_calculate_SLP( T, Td, STP, alt )
%GEN_CALCULATE_SLP Calculates Sea Level Pressure from station pressure,
%altitude, temp and dewpt.
%   SUMMARY:
%       Calculates the Relative Humidity from Temperature and Dew point
%       using the Clausius-Clapeyron equation to get vapor pressure and
%       saturation vapor pressure.
%   
%   INPUTS:
%       T - Temperature (degrees C)
%       Td - Dew point temperature (degrees C)
%       STP - Station pressure (hPa)
%       alt - Station altitude (meters)
%
%   OUTPUTS:
%       SLP - Sea level pressure (hPa)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code is part of a suite of software developed under the guidance of
% Dr. Sandra Yuter and the Cloud Precipitation Processes and Patterns Group
% at North Carolina State University.
% Copyright (C) 2013 Spencer Rhodes and Andrew Hall
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The approximation of the Clausius-Clapeyron equation being applied here
% is ln(e_s,water/611 Pa) = 19.83 - (5417 K/ T).

Tk = T + 273.15;
Tdk = Td + 273.15;
e = 611 * exp(19.83 - (5417 / Tdk));
w = 621.97 * (e / (STP - e));
Tvk = Tk * (1 + 0.61 * w);
SLP = STP * exp((9.81 * alt) / (287 * Tvk));

end

