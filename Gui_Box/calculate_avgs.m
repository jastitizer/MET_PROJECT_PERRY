function [avgs] = calculate_avgs( htmlfilepath, returndata, numstorms, no_pressure , is_cat)
%CALCULATE_AVGS Calculates the averages in a MRR webpage and puts them in
%the correct places in the webpage. Also finds the total precipitation.
%
%   NOTE: You must include the storms folder that contains the storm page
%         html files in the Matlab path in order for this code to work.
%
%   SUMMARY: Calculates the averages of the important graph statistics in
%            an MRR webpage and puts them into the correct spot in the
%            table. The webpage must be designed similarly to Portland and
%            Merwin.
%
%   INPUTS:
%       htmlfilepath - The full file path to the MRR webpage (this can just
%                      be the name of the html file if the file is already
%                      on the Matlab path.
%       returndata - Set to 1 if you want the averages to be returned in a
%                    Matlab struct and not written to the webpage.
%       numstorms - The number of storms on the MRR webpage.
%       no_pressure - Because the Alta website is formatted slightly
%                 differently, you must specify if the website you are
%                 updating is for Alta. Set to 1 if it is Alta, else 0.
%       is_cat - Set to 1 if you are processing a category html page. Must
%                have categories folder on path. 1 = types; 2 = continuity.
%
%   Author: Spencer Rhodes (srrhodes@ncsu.edu)
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

temp = zeros(1,numstorms);
if ~no_pressure, pres = zeros(1,numstorms); end
relh = zeros(1,numstorms);
wdir = zeros(1,numstorms);
wspd = zeros(1,numstorms);
precip = zeros(1,numstorms);
durs = zeros(1,numstorms);

fid = fopen(htmlfilepath);
if fid == -1
    fprintf('Error reading from webpage html file. Try again.\n')
    fclose('all');
    return
end

counter = 1;
keepreading = 1;

while 1
    line = fgetl(fid);
    while isempty(strfind(line, '<!-- Storm'))
        if strfind(line, '<!-- Table entries end -->')
            keepreading = 0;
            break
        end
        
        line = fgetl(fid);
    end
    
    if ~keepreading, break; end % Executes when done reading storms.
    
    fgetl(fid); % Skip <tr> tag
    fgetl(fid); % Skip year
    fgetl(fid); % Skip month
    
    line = fgetl(fid); % This line contains html file of storm page.
    if is_cat == 1
        href = textscan(line, '<td style="border:1px solid black;"><div align="center"><a href="%30.s">%f</a></div></td>');
        stormfid = fopen(['categories/' href{1}{1}]);
    elseif is_cat == 2
        href = textscan(line, '<td style="border:1px solid black;"><div align="center"><a href="%36.s">%f</a></div></td>');
        stormfid = fopen(['categories/' href{1}{1}]);
    else
        href = textscan(line, '<td style="border:1px solid black;"><div align="center"><a href="%25.s">%f</a></div></td>');
        stormfid = fopen(href{1}{1});
    end
    if stormfid ~= -1
        stormline = fgetl(stormfid);
        while isempty(strfind(stormline, 'Avg. Wind Direction:'))
            stormline = fgetl(stormfid);
        end
        
        winddir = textscan(stormline, '%75c%f%16c');
        if isempty(winddir{2}), wdir(counter) = NaN;
        else wdir(counter) = winddir{2}; end
        clear winddir
        
        stormline = fgetl(stormfid);
        while isempty(strfind(stormline, 'Average'))
            stormline = fgetl(stormfid);
        end
        
        fgetl(stormfid); % Skip average temperature
        
        if ~no_pressure
            stormline = fgetl(stormfid); % This line contains average pressure.
            pressure = textscan(stormline, '<td style="border:1px solid black;"><div align="center">%f hPa </td>');
            pres(counter) = pressure{1}; clear pressure
        end
        
        stormline = fgetl(stormfid); % This line contains average rel hum.
        relhumidity = textscan(stormline, '<td style="border:1px solid black;"><div align="center">%f%%</div></td>');
        relh(counter) = relhumidity{1}; clear relhumidity
        
        fclose(stormfid);
        clear stormfid
    else
        fprintf('Error reading from storm page html file. Try again.\n')
        fclose('all');
        return
    end
    clear href
    
    if ~is_cat
        fgetl(fid); % Skip storm Type
    end
    if ~no_pressure
        fgetl(fid); % Skip AGL
    end
    fgetl(fid); % Skip Continuity
    fgetl(fid); % Skip start time
    
    line = fgetl(fid); % This line contains the storm duration.
    duration = textscan(line, '<td style="border:1px solid black;"><div align="center">%f</div></td>');
    durs(counter) = duration{1}; clear duration
    
    line = fgetl(fid); % This line contains the average temperature.
    temperature = textscan(line, '<td style="border:1px solid black;"><div align="center">%f</div></td>');
    temp(counter) = temperature{1}; clear temperature
    
    fgetl(fid); % Skip avg wind direction
    fgetl(fid); % Skip peak wind direction
    
    line = fgetl(fid); % This line contains the average wind speed.
    windspeed = textscan(line, '<td style="border:1px solid black;"><div align="center">%f</div></td>');
    if isempty(windspeed{1}), wspd(counter) = NaN;
    else wspd(counter) = windspeed{1}; end
    clear windspeed
    
    if no_pressure, fgetl(fid); end % Skip Wildcat Lift wind speed for alta page
    
    line = fgetl(fid); % This line contains the total precipitation.
    precipitation = textscan(line, '<td style="border:1px solid black;"><div align="center">%f</div></td>');
    if isempty(precipitation{1}), precip(counter) = 0;
    else precip(counter) = precipitation{1}; end
    clear precipitation
    
    counter = counter + 1;
end

fclose('all');
clear fid

avgtemp = nanmean(temp);
if ~no_pressure, avgpres = nanmean(pres); else avgpres = NaN; end
avgrelh = nanmean(relh);
avgwdir = gen_calculate_avgwdir(wdir);
avgwspd = nanmean(wspd);
avgdurs = nanmean(durs);
avgprecip = nanmean(precip);
totalprecip = sum(precip);

if returndata == 1
    avgs.temp = avgtemp;
    avgs.pres = avgpres;
    avgs.relh = avgrelh;
    avgs.wdir = avgwdir;
    avgs.wspd = avgwspd;
    avgs.durs = avgdurs;
    avgs.precip = avgprecip;
    avgs.totalprecip = totalprecip;
    return
end

frid = fopen(htmlfilepath);
fwid = fopen([strrep(htmlfilepath,'.html','') '_update.html'], 'w');

line = fgets(frid);
while isempty(strfind(line, 'Average'))
    fprintf(fwid, line);
    line = fgets(frid);
end

for i = 1:5
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', avgtemp);

for i = 1:4
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', avgrelh);

for i = 1:4
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', avgwdir);

for i = 1:4
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', avgwspd);

if ~no_pressure
    for i = 1:4
        fprintf(fwid, line);
        line = fgets(frid);
    end
    line = sprintf('\t\t\t<td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', avgpres);
end

for i = 1:4
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', avgprecip);

while isempty(strfind(line, 'Total Precipitation'))
    fprintf(fwid, line);
    line = fgets(frid);
end

for i = 1:3
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;" colspan="7" align="center"><strong> %.2f </strong></td>\n', totalprecip);

for i = 1:9
    fprintf(fwid, line);
    line = fgets(frid);
end
line = sprintf('\t\t\t<td style="border:1px solid black;" colspan="7" align="center"><strong> %.2f </strong></td>\n', avgdurs);

while line ~= -1
    fprintf(fwid, line);
    line = fgets(frid);
end

fclose('all');
delete(htmlfilepath)
movefile([strrep(htmlfilepath,'.html','') '_update.html'], htmlfilepath);
clear frid fwid


end

