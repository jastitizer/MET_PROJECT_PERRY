function add_next_prev( htmlfile, homelocation, stormsummarypg, is_cat, first_storm )
%ADD_NEXT_PREV Summary of this function goes here
%   htmlfile - just the html file (no path; include '.html')
%   homelocation - The reference location of the home page e.g. './'
%   stormsummarypg - Reference location to the storm summary from where the
%   user came to the current storm page. Varies based on year and
%   categories.
%   is_cat - Set to empty string if setting the next and prev buttons for a
%   overall storm summary. For categories, set to either 'type/' or
%   'continuity/'.
%   first_storm - Set to the filename of the first html storm file that
%   needs buttons to be updated.  If you do not need to use this, set to ''
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

storms = struct([]);
fid = fopen(htmlfile);
line = fgetl(fid);
counter = 0;

while 1
    if is_cat
        while isempty(strfind(line, ['storms_' is_cat])) && isempty(strfind(line, 'Version'))
            line = fgetl(fid);
        end
    elseif first_storm
        while isempty(strfind(line, ['storms/' first_storm])) && isempty(strfind(line, 'Version'))
            line = fgetl(fid);
        end
        first_storm = 0;
    else
        while isempty(strfind(line, 'storms/')) && isempty(strfind(line, 'Version'))
            line = fgetl(fid);
        end
    end
    
    if ~isempty(strfind(line, 'Version')), break; end
    
    counter = counter + 1;
    if counter == 1;
        rememberlast = textscan(line, '%s %s %s %s', 'Delimiter', '"');
        rememberlast = rememberlast{2}{2};
        storms(counter).cur = rememberlast(8+length(is_cat):end);
    else
        thisstorm = textscan(line, '%s %s %s %s', 'Delimiter', '"');
        thisstorm = thisstorm{2}{2};
        storms(counter - 1).next = thisstorm(8+length(is_cat):end);
        storms(counter).cur = thisstorm(8+length(is_cat):end);
        storms(counter).prev = rememberlast(8+length(is_cat):end);
        rememberlast = thisstorm;
    end
    line = fgetl(fid);
end
fclose('all');

for i = 1:length(storms)
    if is_cat
        frid = fopen(['categories/storms_' is_cat storms(i).cur]);
    else
        frid = fopen(['storms/' storms(i).cur]);
    end
    date = storms(i).cur; date = date(1:end-5);
    fwid = fopen('temp_stormpage.html','w');
    line = fgets(frid);
    
    while isempty(strfind(line, '// Home'))
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    line = ['    loc = "' homelocation '" // Home\n'];
    while isempty(strfind(line, '// Previous Summary'))
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    line = ['    loc = "' stormsummarypg '"; // Previous Summary\n'];
    while isempty(strfind(line, 'Previous Storm'))
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if ~isfield(storms, 'prev') || isempty(storms(i).prev)
        if i ~= 1 || isempty(first_storm)
            line = '    <td width="400" align="right"><input type="button" style="visibility:hidden;" value="Previous Storm" onclick=""></td>\n';
        end
    else
        line = ['    <td width="400" align="right"><input type="button" style="visibility:visible;" value="Previous Storm" onclick="land(''' ...
            storms(i).prev ''',''_self'')"></td>\n'];
    end
    while isempty(strfind(line, 'Next Storm'))
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if ~isfield(storms, 'next') || isempty(storms(i).next)
        line = '    <td width="400" align="left"><input type="button" style="visibility:hidden;" value="Next Storm" onclick=""></td>\n';
    else
        line = ['    <td width="400" align="left"><input type="button" style="visibility:visible;" value="Next Storm" onclick="land(''' ...
            storms(i).next ''',''_self'')"></td>\n'];
    end
    
  if is_cat
    while isempty(strfind(line, date))
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while isempty(strfind(line, date)) && min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if line == -1
        fclose('all');
        delete(['categories/storms_' is_cat storms(i).cur])
        movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
        continue
    end
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while isempty(strfind(line, date)) && min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if line == -1
        fclose('all');
        delete(['categories/storms_' is_cat storms(i).cur])
        movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
        continue
    end
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while isempty(strfind(line, date)) && min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if line == -1
        fclose('all');
        delete(['categories/storms_' is_cat storms(i).cur])
        movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
        continue
    end
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while isempty(strfind(line, date)) && min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if line == -1
        fclose('all');
        delete(['categories/storms_' is_cat storms(i).cur])
        movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
        continue
    end
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while isempty(strfind(line, date)) && min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if line == -1
        fclose('all');
        delete(['categories/storms_' is_cat storms(i).cur])
        movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
        continue
    end
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while isempty(strfind(line, date)) && min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    if line == -1
        fclose('all');
        delete(['categories/storms_' is_cat storms(i).cur])
        movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
        continue
    end
    line = strrep(line, date, ['../../storms/' date]);
    fprintf(fwid, line); line = fgets(frid);
    while min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    fclose('all');
    delete(['categories/storms_' is_cat storms(i).cur])
    movefile('temp_stormpage.html',['categories/storms_' is_cat storms(i).cur])
    
  else
    while min(line ~= -1)
        fprintf(fwid, line);
        line = fgets(frid);
    end
    
    fclose('all');
    delete(['storms/' storms(i).cur])
    movefile('temp_stormpage.html',['storms/' storms(i).cur])
  end
  
end
    
    

end

