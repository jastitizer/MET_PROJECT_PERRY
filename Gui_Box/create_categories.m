function create_categories( htmlfilename, numstorms, numyears, is_alta )
%CREATE_CATEGORIES Summary of this function goes here
%
%   For this function to work, you must have used frontpage.html as your
%   template.
%
%   Do not include .html in htmlfile name.
%
%   Put storms folder one above workspace.
%
%   Make sure to adjust code for changing relative path correctly in
%   script.
%
%   numyears is the number of seasons in the drop down menu.
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

types = cell(1,1);
storms = cell(1,numstorms);

% Path to the new html files.
pathtohtml = '';
filepath = pathtohtml;

fid = fopen([pathtohtml htmlfilename '.html']);

% Skip through webpage to storms.
line = fgets(fid);
while isempty(strfind(line, '<!-- Storm'))
    line = fgets(fid);
end

% This loop runs through all the storms in the webpage and stores the table
% information about each storm in the storms cell array. Each cell contains
% a struct containing the storm's start date (yyyymmdd_HHMM), type,
% continuity, and the table information.
keepreading = 1;
countstorms = 0;
while keepreading
    countstorms = countstorms + 1;
    stormid = textscan(line,'%s %s %s %s');
    storm.id = stormid{3}{1};
    
    % Skip <tr> tag, year, month, and day.
    storm.content1 = strcat(line, '\n');
    for i = 1:4
        line = fgets(fid);
        storm.content1 = strcat(storm.content1, line, '\n');
    end
    
    % Get the type.
    line = fgets(fid);
    type = textscan(line, '<td style="border:1px solid black;"><div align="center">%s', 'Delimiter', '<');
    storm.type = type{1}{1};
    storm.content2 = strcat(line, '\n');
    
    % Skip the AGL (will not make sub category for agls; too cumbersome).
    if ~is_alta
        line = fgets(fid);
        storm.content3 = strcat(line, '\n');
    end
    
    % Get the continuity.
    line = fgets(fid);
    cont = textscan(line, '%s %s %s %s', 'Delimiter', '>');
    cont = strrep(cont{4}{1}, '</font', '');
    storm.continuity = cont;
    storm.content4 = strcat(line, '\n');
    
    % Get the rest of the table information.
    line = fgets(fid);
    storm.content5 = '';
    while isempty(strfind(line, '<!-- Storm')) && ...
          isempty(strfind(line, '<!-- Table entries end -->'))
        storm.content5 = strcat(storm.content5, line, '\n');
        line = fgets(fid);
    end
    
    % Store the struct in the storms cell array.
    storms{countstorms} = storm;
    clear storm
    
    % If the end of the storms has been reached, stop running this loop.
    if ~isempty(strfind(line, '<!-- Table entries end -->'))
        keepreading = 0;
        fclose('all');
    end
    
end

% This loop gets all the different types from the cell array of storms and
% records them in the types cell array. It also counts the number of each
% type that there are, if there are more than one. In addition, this loop
% counts the number of scattered and continuous storms.
counter = 0;
continuous = 0;
scattered = 0;
for i = 1:numstorms
    storm = storms{i};
    foundtype = find(strcmp(types, storm.type));
    if foundtype
        typescount(foundtype) = typescount(foundtype) + 1;
    else
        counter = counter + 1;
        types{counter} = storm.type;
        typescount(counter) = 1;
    end
    
    if strcmp('Continuous', storm.continuity)
        continuous = continuous + 1;
    else scattered = scattered + 1;
    end
    
end
[types indices] = sort(types);
% Rematch the typescount numbers to the rearranged indices
for i = 1:length(types)
    typescount_temp(i) = typescount(indices(i));
end
typescount = typescount_temp;
clear indices typescount_temp

% Store the Types html file names.
typehtml = cell(1, length(types));
for i = 1:length(types)
    type = types{i};
    capitals = find(ismember(type, 'A':'Z'));
    filestr = '';
    if length(capitals) > 1
        for j = 1:length(capitals)-1
            filestr = [filestr type(capitals(j))];
        end
        % filestr e.g. '/path/categories/alta_2011_RVRain.html'
        filestr = [htmlfilename '_' filestr type(capitals(end):end) '.html'];
    else
        filestr = [htmlfilename '_' type '.html'];
    end
    typehtml{i} = filestr;
end

% Generate the webpages for the different types of storms.
for i = 1:length(types)
    % First get all the storms in the current type indexed by i
    type = types{i};
    countstorms = 0;
    for j = 1:length(storms)
        storm = storms{j};
        if strcmp(storm.type, type)
            countstorms = countstorms + 1;
            indexofstorms(countstorms) = j;
        end
    end
    
    fid = fopen([pathtohtml htmlfilename '.html']);
    fwid = fopen('temporary_webpage.html','w');
    
    % Changes the paths that go back to Home or other website to go up one
    % folder from categories.
    line = fgets(fid);
    while isempty(strfind(line, '// Home'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    line = strrep(line, './', '../'); fprintf(fwid, line);
    line = fgets(fid);
    for k = 1:2
        while isempty(strfind(line, 'loc ='))
            fprintf(fwid, line); line = fgets(fid);
        end
        line = strrep(line, './', '../'); fprintf(fwid, line);
        line = fgets(fid);
    end
    
    while isempty(strfind(line, 'Storm Summary'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    % This section produces the title of the new html page.
    thisline = textscan(line, '<td width = "800" align="center" class="style3 style4">%s', ...
        'Delimiter', '<');
    stormline = strrep(thisline{1}{1},num2str(numstorms),num2str(typescount(i)));
    line = ['    <td width = "800" align="center" class="style3 style4">' types{i} ' ' stormline '</td>\n'];
    clear stormline thisline
    fprintf(fwid, line);
    
    % Change the links back to the original pages to go up a folder.
    line = fgets(fid);
    while isempty(strfind(line, 'option value'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    % Skip Changes comments.
    for j = 1:6, fprintf(fwid, line); line = fgets(fid); end
    
    % Change the options.
    for j = 1:numyears
        if ~isempty(strfind(line, htmlfilename))
            line = strrep(line, 'option value', 'option selected="selected" value');
        end
        line = strrep(line, '"./', '"../');
        fprintf(fwid, line); line = fgets(fid);
    end
    
    % Print all lines up to Storm Types to new html page.
    while isempty(strfind(line, 'Choose a type'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    % Print the types into the form.
    fprintf(fwid, line);
    for j = 1:length(types)
        fprintf(fwid, ['        <option value="./' typehtml{j} '">' types{j} '</option>\n']);
    end
    
    % Move down to Continuous button.
    line = fgets(fid);
    while isempty(strfind(line, '_Continuous.html'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    href = [htmlfilename '_Continuous.html'];
    fprintf(fwid, ['        <input type="button" value="Continuous" onclick="land(''./' href ''',''_self'')">\n']);
    
    % Move down to Scattered button.
    fgets(fid);
    href = [htmlfilename '_Scattered.html'];
    fprintf(fwid, ['        <input type="button" value="Scattered" onclick="land(''./' href ''',''_self'')">\n']);    
    line = fgets(fid);
    
  %%% IMPORTANT: Need to change the column labels at the top before taking
    % out the type column.
    if is_alta, colspan = 8; else colspan = 9; end
    while isempty(strfind(line, ['colspan="' num2str(colspan) '"']))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    line = strrep(line, ['colspan="' num2str(colspan) '"'], ['colspan="' num2str(colspan-1) '"']);
    
    % Don't need the column of Type in the storm table.
    while isempty(strfind(line, 'Type'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    line = fgets(fid);
    
    % Write to new html file up to where storms start.
    while isempty(strfind(line, '<!-- Storm'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    % Write all the storms of the current type to the new html file.
    for j = 1:length(indexofstorms)
        stormtowrite = storms{indexofstorms(j)};
        specialcontent = strrep(stormtowrite.content1, 'storms', 'storms_type');
        fprintf(fwid, specialcontent);
        clear specialcontent
        % Skip type
        if ~is_alta, fprintf(fwid, stormtowrite.content3); end
        fprintf(fwid, stormtowrite.content4);
        fprintf(fwid, stormtowrite.content5);
    end
    clear indexofstorms
    
    % Skip the reader down to the end of the table.
    while isempty(strfind(line, '<!-- Table entries end -->'))
        line = fgets(fid);
    end
    
    % Write the bottom of the frontpage to the new html file.
    while line ~= -1
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    fclose('all');
    
    % Now have to go back through and add the averages of the new html
    % file's storms to the new html file.
    stormavgs = calculate_avgs('temporary_webpage.html',1,countstorms,is_alta,1);
    fid = fopen('temporary_webpage.html'); line = fgets(fid);
    fwid = fopen([filepath 'categories/' typehtml{i}], 'w');
    while isempty(strfind(line, 'Average'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    for j = 1:2, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid,'      <td style="border:1px solid black;"><div align="center"><strong>Page</strong></div></td>\n');
        
    for j = 1:4, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid,'      <td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', stormavgs.temp);
    
    for j = 1:4, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid,'      <td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', stormavgs.relh);
    
    for j = 1:4, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid,'      <td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', stormavgs.wdir);
    
    for j = 1:4, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid,'      <td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', stormavgs.wspd);
    
    if ~is_alta
        for j = 1:4, fprintf(fwid, line); line = fgets(fid); end
        fprintf(fwid,'      <td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', stormavgs.pres);
    end
    
    for j = 1:4, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid,'      <td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', stormavgs.precip);
    
    while isempty(strfind(line, 'Total Precipitation'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid, '    <tr>\n');
    fprintf(fwid, '      <td style="border:1px solid black;" colspan="7" align="center"><strong> This page: %.2f </strong></td>\n', stormavgs.totalprecip);
    fprintf(fwid, '    </tr>\n');
    
    while isempty(strfind(line, 'Avg. Duration'))
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
    fprintf(fwid, '    <tr>\n');
    fprintf(fwid, '      <td style="border:1px solid black;" colspan="7" align="center"><strong> This page: %.2f </strong></td>\n', stormavgs.durs);
    fprintf(fwid, '    </tr>\n');
    
    while line ~= -1
        fprintf(fwid, line);
        line = fgets(fid);
    end
    
    fclose('all');
    delete('temporary_webpage.html');
    
end

% Run add_next_prev_v3 to make the storms in the storms folder in
% categories point to the correct next and previous storms according to the
% category pages.
for i = 1:length(types)
    add_next_prev(['categories/' typehtml{i}],'../../',['../' typehtml{i}],'type/','')
end

%%%%%% Make new frontpage %%%%%%
fid = fopen([pathtohtml htmlfilename '.html']);
fwid = fopen('updated_frontpage.html', 'w');

line = fgets(fid);
while isempty(strfind(line, 'Choose a type'))
    fprintf(fwid, line);
    line = fgets(fid);
end

% Print the types into the form.
fprintf(fwid, line);
for j = 1:length(types)
    fprintf(fwid, ['        <option value="categories/' typehtml{j} '">' types{j} '</option>\n']);
end

% Move down to Continuous button.
line = fgets(fid);
% while isempty(strfind(line, 'Continuous'))
%     fprintf(fwid, line);
%     line = fgets(fid);
% end
% href = [htmlfilename '_Continuous.html'];
% fprintf(fwid, ['        <input type="button" value="Continuous" onclick="land(''categories/' href ''',''_self'')">\n']);
% clear href
% 
% % Move down to Scattered button.
% fgets(fid);
% href = [htmlfilename '_Scattered.html'];
% fprintf(fwid, ['        <input type="button" value="Scattered" onclick="land(''categories/' href ''',''_self'')">\n']);    
% line = fgets(fid);
% clear href

while line ~= -1
    fprintf(fwid, line);
    line = fgets(fid);
end

fclose('all');
delete([pathtohtml htmlfilename '.html'])
movefile('updated_frontpage.html',[pathtohtml htmlfilename '.html']);


%%%%% TODO MAKE SCATTERED AND CONTINUOUS HTML PAGES %%%%%%
countscattered = 0;
countcontinuous = 0;
for i = 1:length(storms)
    storm = storms{i};
    if strcmp(storm.continuity, 'Scattered')
        countscattered = countscattered + 1;
        i_scattered(countscattered) = i;
    else
        countcontinuous = countcontinuous + 1;
        i_continuous(countcontinuous) = i;
    end
end; clear countscattered countcontinuous

fid = fopen([filepath 'categories/' typehtml{1}]);
fsid = fopen('temporary_scattered.html','w');
fcid = fopen('temporary_continuous.html','w');

line = fgets(fid);
while isempty(strfind(line, 'Storm Summary'))
    fprintf(fsid, line); fprintf(fcid, line);
    line = fgets(fid);
end

% This section produces the title of the new html page.
thisline = textscan(line, '<td width = "800" align="center" class="style3 style4">%s', ...
    'Delimiter', '<');
thisline = thisline{1}{1};
stormline = strfind(thisline, 'Storm Summary');
stormline = thisline(stormline:end);
stormline1 = strrep(stormline,[num2str(typescount(1)) ' Storms'], ...
    [num2str(scattered) ' Storms']);
stormline2 = strrep(stormline,[num2str(typescount(1)) ' Storms'], ...
    [num2str(continuous) ' Storms']);
line1 = ['<td width = "800" align="center" class="style3 style4"> Scattered ' stormline1 '</td>\n'];
line2 = ['<td width = "800" align="center" class="style3 style4"> Continuous ' stormline2 '</td>\n'];
clear stormline thisline
fprintf(fsid, line1); fprintf(fcid, line2);

line = fgets(fid);
while isempty(strfind(line, 'Trends'))
    fprintf(fsid, line); fprintf(fcid, line);
    line = fgets(fid);
end

for i = 1:12, fprintf(fsid, line); fprintf(fcid, line); line = fgets(fid); end
fprintf(fsid, '      <td width="100" style="border:1px solid black;"><div align="center"><strong>Type</strong></div></td>\n');
fprintf(fcid, '      <td width="100" style="border:1px solid black;"><div align="center"><strong>Type</strong></div></td>\n');
fprintf(fsid, line); fprintf(fcid, line); fgets(fid);
line = fgets(fid);
while isempty(strfind(line, '<!-- Storm'))
    fprintf(fsid, line); fprintf(fcid, line);
    line = fgets(fid);
end

for i = 1:length(i_scattered)
    stormtowrite = storms{i_scattered(i)};
    specialcontent = strrep(stormtowrite.content1, 'storms', 'storms_continuity');
    fprintf(fsid, specialcontent);
    clear specialcontent
    fprintf(fsid, stormtowrite.content2);
    if ~is_alta, fprintf(fsid, stormtowrite.content3); end
    % Skip continuity
    fprintf(fsid, stormtowrite.content5);
end; clear i_scattered
for i = 1:length(i_continuous)
    stormtowrite = storms{i_continuous(i)};
    specialcontent = strrep(stormtowrite.content1, 'storms', 'storms_continuity');
    fprintf(fcid, specialcontent);
    clear specialcontent
    fprintf(fcid, stormtowrite.content2);
    if ~is_alta, fprintf(fcid, stormtowrite.content3); end
    % Skip continuity
    fprintf(fcid, stormtowrite.content5);
end; clear i_continuous

while isempty(strfind(line, '<!-- Table entries end -->'))
    line = fgets(fid);
end

while line ~= -1
    fprintf(fsid, line); fprintf(fcid, line);
    line = fgets(fid);
end
fclose('all');


% Scattered html page.
stormavgs = calculate_avgs('temporary_scattered.html',1,scattered,is_alta,2);
fid = fopen('temporary_scattered.html'); line = fgets(fid);
fwid = fopen([filepath 'categories/' htmlfilename '_Scattered.html'], 'w');

while isempty(strfind(line, 'Average'))
    fprintf(fwid, line);
    line = fgets(fid);
end

for j = 1:7, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', stormavgs.temp);

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', stormavgs.relh);

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', stormavgs.wdir);

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', stormavgs.wspd);

if ~is_alta
    for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
    line = sprintf('      <td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', stormavgs.pres);
end

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', stormavgs.precip);

while isempty(strfind(line, 'Total Precipitation'))
    fprintf(fwid, line);
    line = fgets(fid);
end

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
fprintf(fwid, '    <tr>\n');
fprintf(fwid, '      <td style="border:1px solid black;" colspan="7" align="center"><strong> This page: %.2f </strong></td>\n', stormavgs.totalprecip);
fprintf(fwid, '    </tr>\n');
for j = 1:3, line = fgets(fid); end % Skip old this page.

while isempty(strfind(line, 'Avg. Duration'))
    fprintf(fwid, line);
    line = fgets(fid);
end

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
fprintf(fwid, '    <tr>\n');
fprintf(fwid, '      <td style="border:1px solid black;" colspan="7" align="center"><strong> This page: %.2f </strong></td>\n', stormavgs.durs);
fprintf(fwid, '    </tr>\n');
for j = 1:3, line = fgets(fid); end

while line ~= -1
    fprintf(fwid, line);
    line = fgets(fid);
end
fclose('all');
delete('temporary_scattered.html');


% Continuous html page.
stormavgs = calculate_avgs('temporary_continuous.html',1,continuous,is_alta,2);
fid = fopen('temporary_continuous.html'); line = fgets(fid);
fwid = fopen([filepath 'categories/' htmlfilename '_Continuous.html'], 'w');
while isempty(strfind(line, 'Average'))
    fprintf(fwid, line);
    line = fgets(fid);
end

for j = 1:7, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', stormavgs.temp);

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', stormavgs.relh);

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', stormavgs.wdir);

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.1f</div></td>\n', stormavgs.wspd);

if ~is_alta
    for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
    line = sprintf('      <td style="border:1px solid black;"><div align="center">%.0f</div></td>\n', stormavgs.pres);
end

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
line = sprintf('      <td style="border:1px solid black;"><div align="center">%.2f</div></td>\n', stormavgs.precip);

while isempty(strfind(line, 'Total Precipitation'))
    fprintf(fwid, line);
    line = fgets(fid);
end

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
fprintf(fwid, '    <tr>\n');
fprintf(fwid, '      <td style="border:1px solid black;" colspan="7" align="center"><strong> This page: %.2f </strong></td>\n', stormavgs.totalprecip);
fprintf(fwid, '    </tr>\n');
for j = 1:3, line = fgets(fid); end

while isempty(strfind(line, 'Avg. Duration'))
    fprintf(fwid, line);
    line = fgets(fid);
end

for j = 1:5, fprintf(fwid, line); line = fgets(fid); end
fprintf(fwid, '    <tr>\n');
fprintf(fwid, '      <td style="border:1px solid black;" colspan="7" align="center"><strong> This page: %.2f </strong></td>\n', stormavgs.durs);
fprintf(fwid, '    </tr>\n');
for j = 1:3, line = fgets(fid); end

while line ~= -1
    fprintf(fwid, line);
    line = fgets(fid);
end
fclose('all');
delete('temporary_continuous.html');

add_next_prev([filepath 'categories/' htmlfilename '_Scattered.html'], ...
    '../../',['../' htmlfilename '_Scattered.html'],'continuity/','')
add_next_prev([filepath 'categories/' htmlfilename '_Continuous.html'], ...
    '../../',['../' htmlfilename '_Continuous.html'],'continuity/','')



end

