function [ avgwdir ] = gen_calculate_avgwdir( array_of_wdir )
%GEN_CALCULATE_AVGWDIR Calculate average meteorological wind direction from array of meteorological wind directions.
%   Computes the average wind direction of a given array of meteorological
%   wind directions. The wind direction outputted by the function is also
%   in meteorological format (i.e. Compass degrees).
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

for i = length(array_of_wdir):-1:1
    if isnan(array_of_wdir(i))
        array_of_wdir(i) = [];
    end
end

u_cart = cosd(-array_of_wdir - 90);
v_cart = sind(-array_of_wdir - 90);

u_avg = nanmean(u_cart);
v_avg = nanmean(v_cart);

avgwdir = uv2wdir(-u_avg, -v_avg);

function [ winddir ] = uv2wdir( uwind,vwind)
    %converts u and v components of wind (cartesian) into meterological wind direction
    %by breaking into quadrants and adding 0,pi, or 2pi to arctan
    %outputs in degrees azimuth
    %quadrants are cartesian (I=NE Quad; II=NW Quad; III=SW Quad; IV=SE Quad)
    %author: Matt Wilbanks
    winddir=uwind*NaN;
    a=rad2deg(atan(abs(vwind)./abs(uwind)));

    winddirI=vwind>=0 & uwind>=0;
    winddir(winddirI)= mod((90- a(winddirI)),360);

    winddirII=vwind>=0 & uwind<0;
    winddir(winddirII)= mod((a(winddirII)-90),360);

    winddirIII=vwind<0 & uwind<0;
    winddir(winddirIII)=mod(-(90+a(winddirIII)),360);

    winddirIV=vwind<0 & uwind>=0;
    winddir(winddirIV)=mod((a(winddirIV)-270),360);

end

end

