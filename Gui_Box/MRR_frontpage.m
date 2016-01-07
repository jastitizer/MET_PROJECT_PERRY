function [ status ] = MRR_frontpage( stormData, settings )
% MRR_frontpage - Reads in the input from settings.frontpage_orig
%               - Writes the input from the original html file to
%                 a new html file inputted by
%                 settings.frontpage_saveas
%               - Writes the stormData given from the input at the
%                 end of the current table storm data in the new
%                 html file
%
%   Inputs: 
%       stormData: The data structure containing 19 fields of storm data
%                  which must be properly named according to the function.
%           fields: year, month, day, type, AGL, continuity, start,
%                   duration, avg_temp, avg_winddir, peak_winddir,
%                   wind_speed, precip, temp_before, temp_during,
%                   rh_before, rh_during, pres_before, pres_during.
%       settings: The data structure containing three fields that specify the
%                 original html file location and the new html file name
%                 and location. The third field specifies the number of
%                 storms in the original html file.
%           fields: frontpage_orig, frontpage_saveas.
%
%   Outputs:
%       status: 1 if the function executes all the way through, otherwise 0
%
%   Author: Spencer Rhodes (srrhodes)
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

fclose('all');
status = 0; %% Will change to 1 if the function runs through correctly

%% CELL ONE
% Cell one checks the storm data to assign '--' to blank values and to set
% the font color for certain values.

for stormId = 1:length(stormData)
    
    if isempty(stormData(stormId).duration)
        stormData(stormId).duration = '--';
    else
        stormData(stormId).duration = sprintf('%.1f', stormData(stormId).duration);
    end
    
    if isempty(stormData(stormId).avg_temp)
        stormData(stormId).avg_temp = '--';
    else
        stormData(stormId).avg_temp = sprintf('%.1f', stormData(stormId).avg_temp);
    end
    
    if (isempty(stormData(stormId).peak_winddir) || isnan(stormData(stormId).peak_winddir)) ...
            && ~isempty(stormData(stormId).wind_speed) ...
            && stormData(stormId).wind_speed == 0
        stormData(stormId).peak_winddir = 'No wind';
    elseif isempty(stormData(stormId).peak_winddir)
        stormData(stormId).peak_winddir = '--';
    elseif isnan(stormData(stormId).peak_winddir)
        stormData(stormId).peak_winddir = 'Unknown';
    else
        wdir = stormData(stormId).peak_winddir;
        if wdir <= 22.5
            stormData(stormId).peak_winddir = 'N';
        elseif wdir <= 67.5
            stormData(stormId).peak_winddir = 'NE';
        elseif wdir <= 112.5
            stormData(stormId).peak_winddir = 'E';
        elseif wdir <= 157.5
            stormData(stormId).peak_winddir = 'SE';
        elseif wdir <= 202.5
            stormData(stormId).peak_winddir = 'S';
        elseif wdir <= 247.5
            stormData(stormId).peak_winddir = 'SW';
        elseif wdir <= 292.5
            stormData(stormId).peak_winddir = 'W';
        elseif wdir <= 337.5
            stormData(stormId).peak_winddir = 'NW';
        else
            stormData(stormId).peak_winddir = 'N';
        end, clear wdir
    end
    
    if (isempty(stormData(stormId).avg_winddir) || isnan(stormData(stormId).avg_winddir)) ...
            && ~isempty(stormData(stormId).wind_speed) ...
            && stormData(stormId).wind_speed == 0
        stormData(stormId).peak_winddir = 'No wind';
    elseif isempty(stormData(stormId).avg_winddir)
        stormData(stormId).avg_winddir = '--';
    elseif isnan(stormData(stormId).avg_winddir)
        stormData(stormId).avg_winddir = 'Balanced';
    else
        wdir = stormData(stormId).avg_winddir;
        if wdir <= 22.5
            stormData(stormId).avg_winddir = 'N';
        elseif wdir <= 67.5
            stormData(stormId).avg_winddir = 'NE';
        elseif wdir <= 112.5
            stormData(stormId).avg_winddir = 'E';
        elseif wdir <= 157.5
            stormData(stormId).avg_winddir = 'SE';
        elseif wdir <= 202.5
            stormData(stormId).avg_winddir = 'S';
        elseif wdir <= 247.5
            stormData(stormId).avg_winddir = 'SW';
        elseif wdir <= 292.5
            stormData(stormId).avg_winddir = 'W';
        elseif wdir <= 337.5
            stormData(stormId).avg_winddir = 'NW';
        else
            stormData(stormId).avg_winddir = 'N';
        end, clear wdir
    end
    
    if isempty(stormData(stormId).wind_speed)
        stormData(stormId).wind_speed = '--';
    else
        stormData(stormId).wind_speed = sprintf('%.1f', stormData(stormId).wind_speed);
    end
    
    if isfield(stormData(stormId), 'wind_speed_wildcat')
        stormData(stormId).wind_speed_wildcat = sprintf('%.1f', ...
            stormData(stormId).wind_speed_wildcat);
    end
    
    if isempty(stormData(stormId).precip)
        stormData(stormId).precip = '--';
    elseif stormData(stormId).precip == 0
        stormData(stormId).precip = 'none';
    elseif ~strcmp(stormData(stormId).precip, 'trace')
        stormData(stormId).precip = sprintf('%.2f', stormData(stormId).precip);        
    end
end
        
%% CELL TWO
% Reads in the html file.

orig_fileid = fopen(settings.frontpage_orig, 'r');

line = cell(1,5000);
searchForEntry = 1;

while feof(orig_fileid) == 0
    line{searchForEntry} = fgetl(orig_fileid);
    
    % Record the line number where the table entries end. This line should
    % be before the </tbody> tag or </table> tag.
    if ~isempty(strfind(line{searchForEntry}, '<!-- Table entries end -->'))
        endWriteHead = searchForEntry - 1;
        startWriteTail = searchForEntry;
        searchForEntry = searchForEntry + 1;
    else
        searchForEntry = searchForEntry + 1;
    end
end
endOfFile = searchForEntry;

fclose(orig_fileid);

%% CELL THREE
% Writes the html from the old file and the provided storm data to a new
% html file.

saveas_fileid = fopen(settings.frontpage_saveas, 'w');

for writeCounter = 1:endWriteHead 
    fprintf(saveas_fileid, '%s\n', line{writeCounter});
end

for stormId = 1:length(stormData)
    fprintf(saveas_fileid, ['    <!-- Storm ' stormData(stormId).graphstr ' -->\n']);
    fprintf(saveas_fileid, sprintf('    <tr>\n'));
    
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).year));
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).month));  
    if isfield(stormData(stormId), 'href')
        fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center"><a href="%s">%s</a></div></td>\n', stormData(stormId).href, stormData(stormId).day));
    else
        fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center"><a href="">%s</a></div></td>\n', stormData(stormId).day));
    end
    if ~isfield(settings, 'is_alta')
        fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center">--</div></td>\n');
    end
    fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center">--</div></td>\n');
    fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center">--</div></td>\n');
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).start));
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).duration));
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).avg_temp));
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).avg_winddir));
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).peak_winddir));
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).wind_speed));
    if isfield(stormData(stormId), 'wind_speed_wildcat')
        fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).wind_speed_wildcat));
    end
    fprintf(saveas_fileid, sprintf('      <td style="border:1px solid black;"><div align="center">%s</div></td>\n', stormData(stormId).precip));
    fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center"><font color="#000000">--</font></div></td>\n');
    fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center"><font color="#000000">--</font></div></td>\n');
    fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center"><font color="#000000">--</font></div></td>\n');
    fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center"><font color="#000000">--</font></div></td>\n');
    if ~isfield(settings, 'is_alta')
        fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center"><font color="#000000">--</font></div></td>\n');
        fprintf(saveas_fileid, '      <td style="border:1px solid black;"><div align="center"><font color="#000000">--</font></div></td>\n');
    end
    
    fprintf(saveas_fileid, sprintf('    </tr>\n'));
end

for writeCounter = startWriteTail:endOfFile
    fprintf(saveas_fileid, '%s\n', line{writeCounter});
end

fclose(saveas_fileid);
status = status + 1;

end

