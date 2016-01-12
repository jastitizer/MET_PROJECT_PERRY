function [ metarStruct ] = gen_metar2struct( metarfilepath, ...
    savefilepath )
%GEN_METAR2STRUCT Parses abbreviated format of METAR data into a Matlab struct.
%   SUMMARY:
%       Parses through a given METAR file and puts the important contents
%       into a struct titled 'metarStruct'. The struct can be saved to a
%       .mat file for later use, if specified by savefilepath. If
%       savefilepath is 0, then the struct will be returned by the
%       function. The minuteinterval indicates the hourly annual surface 
%       obs at the start of the file. YOU MUST PROVIDE THIS TO THE 
%       FUNCTION! The function will be able to detect if the minute
%       interval of the surface obs changes, but the initial interval
%       must be provided.
%
%   INPUTS:
%       metarfilepath - The full file path to the METAR file. The file must
%                       be in the Surface Hourly Abbreviated Format
%                       provided from hurricane.ncdc.noaa.gov.
%       savefilepath - The full file path to where you would like to save
%                      the struct. You may set this to 0 if you
%                      would like to have the function return the struct.
%       metartype - Specifies the type of METAR Data being read in. At this
%                   time, the only permitted types is Simplified Hourly
%                   Surface Obs from ncdc.noaa.gov (metartype == 1). NOTE: 
%                   For METAR data from NCDC, this function skips the first
%                   line of the text file (because it assumes the first 
%                   line is the METAR header). Other types may be added
%                   using this variable and if-statements (see code below).
%       minuteinterval - See the summary for use of this variable. This
%                        variable is REQUIRED for the function to run
%                        correctly.
%
%   OUTPUTS:
%       Returns the struct if savefilepath is set to 0. Otherwise,
%       returns 1.
%
%   AUTHOR: Spencer Rhodes (srrhodes@ncsu.edu)
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
%
metarStruct = struct([]);

fid = fopen(metarfilepath);

% Add parsing for another type of txt file here (if necessary).
%if metartype == #

% if metartype == 3 % SBU L13 (South P Lot) MET Data
    fprintf('Reading METAR data using textscan...');
    
    % Format Specifier Fields: (Data appears to be in UTC...)
    % Date (1), Time HH:MM (2), [AM/PM], Outside Temp F (3), Hi Temp (4),
    % Lo Temp (5), Outside Humidity (6), Dew point (7), Avg wind speed MPH
    % (8), Avg wind dir (9), Wind Run? (10), Gust wind speed MPH (11),
    % Gust wind dir (12), Wind chill F (13), Heat index (14), THW index
    % (15), Pressure Hg (16), Rain in day (17), Rain rate (18), Heat D-D
    % (19), Cool D-D (20), In Temp F (21), In Humidity (22), In Dew (23),
    % In Heat (24), In EMC (25), In Air Density (26), Wind Samp (27), Wind
    % Tx (28), ISS Recept (29), Arc. Int. (30)
    dataSPZO = textscan(fid, ['%s %s %s %s %s %s %s %s %s']);
    fprintf('complete.\n');
    fclose('all'); clear fid
    
%     fprintf('Reprocessing times (could take a couple minutes)...');
    % Get rid of the AM/PM cell by converting all times to 24 hour UTC
%     for i = 1:length(dataSPZO{3})
%        time = dataSPZO{3}{i};
       %if length(time) < 5, time = ['0' time]; end %#ok<AGROW>
%        time = datenum(time,'HH:MM');
%        meridiem = dataSPZO{3}{i};
       
       % If the hour is 12 and it's AM, then change the hour to 00.
%        if meridiem == 'a' && strcmp(datestr(time,'HH'),'12')
%            time = time - (12/24);
%            dataSPZO{2}{i} = datestr(time, 'HH:MM');
           
       % If the hour is not 12 and it's PM, then add 12 hours to hour.
%        elseif meridiem == 'p' && ~strcmp(datestr(time,'HH'),'12')
%            time = time + (12/24);
%            dataSPZO{2}{i} = datestr(time, 'HH:MM');
           
       % Otherwise, at least reset the time so that all the times have the
       % format HH:MM (no entries like 1:20 or 4:52, will be 01:20, etc)
%        else
%            dataSPZO{3}{i} = datestr(time, 'HH:MM');
%        end
%     end
%     fprintf('done.\n');
    
    % Clear the AM/PM cell from dataSBU cell array
%     dataSPZO = {dataSPZO{1:2}, dataSPZO{4:end}};
    
    fprintf('Pulling data into metarStruct (will take a while)...');
    % Now we'll go through and pull out all the important variables into
    % the metarStruct
    j = 0;
    for i = 2:length(dataSPZO{1})
        if strcmp(dataSPZO{3}{i}(length(dataSPZO{3}{i})-1:length(dataSPZO{3}{i})),'00') == 0
        else
            j = j+1;
            date = datenum([dataSPZO{2}{i} ' ' dataSPZO{3}{i}], 'mm/dd/yyyy HH:MM');         
            metarStruct(j).date = date;                                                    
            metarStruct(j).temp = str2double(dataSPZO{4}{i});
%         metarStruct(i).maxtemp = (5/9) * (str2double(dataSPZO{4}{i}) - 32);
%         metarStruct(i).mintemp = (5/9) * (str2double(dataSPZO{5}{i}) - 32);
%         metarStruct(i-1).dewpt = str2double(dataSPZO{5}{i});                          
            metarStruct(j).relhum = str2double(dataSPZO{5}{i});   
            metarStruct(j).wspd = str2double(dataSPZO{7}{i});                         
            if strcmp(dataSPZO{9}{i}, 'M')
                metarStruct(j).wdir = NaN;
            else
                metarStruct(j).wdir = str2double(dataSPZO{6}{i});
%            % Convert the string winddir to degrees
%            %%% IMPORTANT: These statements are ordered such that the most
%            %%% common occurence (based on 2014-15 Winter) is first. This
%            %%% minimizes the amount of if-statements that must be executed
%            if strcmp(dataSPZO{9}{i}, 'WNW')
%                metarStruct(i).wdir = 292.5;
%            elseif strcmp(dataSPZO{9}{i}, 'W')
%                metarStruct(i).wdir = 270;
%            elseif strcmp(dataSPZO{9}{i}, 'NW')
%                metarStruct(i).wdir = 315;
%            elseif strcmp(dataSPZO{9}{i}, 'NE')
%                metarStruct(i).wdir = 45;
%            elseif strcmp(dataSPZO{9}{i}, 'SSE')
%                metarStruct(i).wdir = 157.5;
%            elseif strcmp(dataSPZO{9}{i}, 'WSW')
%                metarStruct(i).wdir = 247.5;
%            elseif strcmp(dataSPZO{9}{i}, 'SW')
%                metarStruct(i).wdir = 225;
%            elseif strcmp(dataSPZO{9}{i}, 'SSW')
%                metarStruct(i).wdir = 202.5;
%            elseif strcmp(dataSPZO{9}{i}, 'NNW')
%                metarStruct(i).wdir = 337.5;
%            elseif strcmp(dataSPZO{9}{i}, 'NNE')
%                metarStruct(i).wdir = 22.5;
%            elseif strcmp(dataSPZO{9}{i}, 'S')
%                metarStruct(i).wdir = 180;
%            elseif strcmp(dataSPZO{9}{i}, 'SE')
%                metarStruct(i).wdir = 135;
%            elseif strcmp(dataSPZO{9}{i}, 'ENE')
%                metarStruct(i).wdir = 67.5;
%            elseif strcmp(dataSPZO{9}{i}, 'E')
%                metarStruct(i).wdir = 90;
%            elseif strcmp(dataSPZO{9}{i}, 'N')
%                metarStruct(i).wdir = 0;
%            elseif strcmp(dataSPZO{9}{i}, 'ESE')
%                metarStruct(i).wdir = 112.5;
%            end
            end
%         metarStruct(i).gust = str2double(dataSPZO{11}{i}) * 0.44704;
%         if strcmp(dataSPZO{12}{i}, '---')
%            metarStruct(i).gustdir = NaN;
%         else
%            % Convert the string winddir to degrees
%            %%% IMPORTANT: These statements are ordered such that the most
%            %%% common occurence (based on 2014-15 Winter) is first. This
%            %%% minimizes the amount of if-statements that must be executed
%            if strcmp(dataSPZO{12}{i}, 'WNW')
%                metarStruct(i).gustdir = 292.5;
%            elseif strcmp(dataSPZO{12}{i}, 'W')
%                metarStruct(i).gustdir = 270;
%            elseif strcmp(dataSPZO{12}{i}, 'NW')
%                metarStruct(i).gustdir = 315;
%            elseif strcmp(dataSPZO{12}{i}, 'NE')
%                metarStruct(i).gustdir = 45;
%            elseif strcmp(dataSPZO{12}{i}, 'SSE')
%                metarStruct(i).gustdir = 157.5;
%            elseif strcmp(dataSPZO{12}{i}, 'WSW')
%                metarStruct(i).gustdir = 247.5;
%            elseif strcmp(dataSPZO{12}{i}, 'SW')
%                metarStruct(i).gustdir = 225;
%            elseif strcmp(dataSPZO{12}{i}, 'SSW')
%                metarStruct(i).gustdir = 202.5;
%            elseif strcmp(dataSPZO{12}{i}, 'NNW')
%                metarStruct(i).gustdir = 337.5;
%            elseif strcmp(dataSPZO{12}{i}, 'NNE')
%                metarStruct(i).gustdir = 22.5;
%            elseif strcmp(dataSPZO{12}{i}, 'S')
%                metarStruct(i).gustdir = 180;
%            elseif strcmp(dataSPZO{12}{i}, 'SE')
%                metarStruct(i).gustdir = 135;
%            elseif strcmp(dataSPZO{12}{i}, 'ENE')
%                metarStruct(i).gustdir = 67.5;
%            elseif strcmp(dataSPZO{12}{i}, 'E')
%                metarStruct(i).gustdir = 90;
%            elseif strcmp(dataSPZO{12}{i}, 'N')
%                metarStruct(i).gustdir = 0;
%            elseif strcmp(dataSPZO{12}{i}, 'ESE')
%                metarStruct(i).gustdir = 112.5;
%            end
%         end
%         % Convert Hg to mb
            if strcmp(dataSPZO{8}{i}, '#VALUE!')
                metarStruct(j).pres = NaN;
            else
                metarStruct(j).pres = str2double(dataSPZO{8}{i});
            end
%         % Convert inches to mm
        metarStruct(j).precip1 = str2double(dataSPZO{9}{i});                          %changed to ".precip1" to match MRR_Get_METAR
%         % Convert in/hr to mm/hr
%         metarStruct(i).rainrate = str2double(dataSPZO{18}{i}) * 25.4; 
        
        end
    end
    fprintf('done.\n');
    
    if savefilepath ~= 0
        fprintf('Saving Matlab struct to specified file...')
        save(savefilepath, 'metarStruct')
        metarStruct = 1;
    else
%         clear dataSPZO time meridiem i;
        return;
    end
    fprintf('complete.\n')
    
    return;
end

% if metartype == 2 % Alta Base MET data
%     % Do other type of METAR txt file...
%     
%     fprintf('Reading METAR data using textscan...')
%     dataAbase = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'Delimiter', ',');
%     fprintf('complete.\n')
%     fclose('all'); clear fid
%     
%     % Filter for 60 minute records of ABASE only.
%     output = str2double(dataAbase{1});
%     idx = find(output ~= 229); % Look for output that's not 60 minute.
%     for i = idx
%         for j = 1:length(dataAbase);
%             dataAbase{j}(i) = [];
%         end
%     end
%     clear output idx i j
%     
%     % Make all times 4 characters
%     for i = 1:length(dataAbase{4})
%         if length(dataAbase{4}{i}) < 4
%             if length(dataAbase{4}{i}) == 1
%                 dataAbase{4}(i) = cellstr(['000' dataAbase{4}{i}]);
%             elseif length(dataAbase{4}{i}) == 2
%                 dataAbase{4}(i) = cellstr(['00' dataAbase{4}{i}]);
%             elseif length(dataAbase{4}{i}) == 3
%                 dataAbase{4}(i) = cellstr(['0' dataAbase{4}{i}]);
%             end
%         end
%     end
%     
%     % Create UTC datenum array for ABase data
%     fprintf('Converting ABase MST to UTC...\n');
%     year = str2double(dataAbase{2});
%     day = str2double(dataAbase{3});
%     time = cell2mat(dataAbase{4});
%     abaseUTC = zeros(1,length(year));
%     for i = 1:length(year)
%         hour = time(i,1:2); minute = time(i,3:4);
%         UTCdate = TimezoneConvert(datenum([year(i) 0 day(i) str2num(hour) str2num(minute) 0]), 'MST', 'UTC'); %#ok<ST2NM>
%         UTCdate = datevec(UTCdate); UTCdate(6) = 0;
%         abaseUTC(i) = datenum(UTCdate);
%         clear hour minute UTCdate
%     end
%     clear year day time i
%     
%     % Assign variables to metarStruct
%     for i = 1:length(abaseUTC)
%         metarStruct(i).date = abaseUTC(i);
%         metarStruct(i).temp = (5/9) * (str2double(dataAbase{8}{i}) - 32); % Conversion to C
%         metarStruct(i).wdir = str2double(dataAbase{7}{i});
%         metarStruct(i).wspd = str2double(dataAbase{6}{i}) * 0.44704; % Conversion factor for mph to m/s
%         metarStruct(i).gust = str2double(dataAbase{5}{i}) * 0.44704;
%         metarStruct(i).wildcatWspd = str2double(dataAbase{10}{i}) * 0.44704;
%         metarStruct(i).wildcatGust = str2double(dataAbase{9}{i}) * 0.44704;
%         metarStruct(i).relhum = str2double(dataAbase{13}{i});
%         metarStruct(i).precip1 = str2double(dataAbase{15}{i}) * 25.4; % Conversion factor for in to mm
%         metarStruct(i).precipY = str2double(dataAbase{17}{i}) * 25.4;
%     end
%     
%     if savefilepath ~= 0
%         fprintf('Saving Matlab struct to specified file...')
%         save(savefilepath, 'metarStruct')
%         metarStruct = 1;
%     else
%         return
%     end
%     fprintf('complete.\n')
%     
%     return
% end

% fgets(fid);
% % Format specifier fields:
% % USAF(1) WBAN(2) YR--MODAHRMN(3) DIR(4) SPD(5) GUS(6) CLG(7) SKC(8) L(9)
% % M(10) H(11) VSB(12) MW(13) MW(14) MW(15) MW(16) AW(17) AW(18) AW(19)
% % AW(20) W(21) TEMP(22) DEWP(23) SLP(24) ALT(25) STP(26) MAX(27) MIN(28)
% % PCP01(29) PCP06(30) PCP24(31) PCPXX(32) SD(33)
% fprintf('Reading METAR data using textscan...')
% data = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s');
% fprintf('complete.\n')
% 
% % Make adjustments for when trace amounts are reported. Trace amounts are
% % not space delimited, so the fields must be moved over and adjusted.
% %
% % NOTE: This change is only necessary if the field after the trace report
% % is stars (e.g. '*****'). If a rain amount is reported after a trace
% % amount, they are space delimited correctly, and no adjustment is
% % required. SECOND NOTE: Another way of handling this would be to read the
% % file and replace all substrings of 'T' with 'T '
% fprintf('Parsing METAR data into Matlab struct. This could take a few minutes...')
% for i = 1:length(data{1})
%     % If the hour precip reports trace, move everything to the left one and
%     % change the hour precip to 0.00T
%     if strcmp(data{29}{i}, '0.00T*****')
%         data{33}(i) = data{32}(i);
%         data{32}(i) = data{31}(i);
%         data{31}(i) = data{30}(i);
%         data{30}{i} = '*****';
%         data{29}{i} = '0.00T';
%     end
%     % If the 6 hour precip reports trace, move everything to the left one
%     % and change the 6 hour precip to 0.00T
%     if strcmp(data{30}{i}, '0.00T*****')
%         data{33}(i) = data{32}(i);
%         data{32}(i) = data{31}(i);
%         data{31}{i} = '*****';
%         data{30}{i} = '0.00T';
%     end
%     % If the 24 hour precip reports trace, move everything to the left one
%     % and change the 24 hour precip to 0.00T
%     if strcmp(data{31}{i}, '0.00T*****')
%         data{33}(i) = data{32}(i);
%         data{32}{i} = '*****';
%         data{31}{i} = '0.00T';
%     end
%     % If the PCPXX precip reports trace, change it to 0.00T and make the
%     % last field equal to **
%     if strcmp(data{32}{i}, '0.00T**')
%         data{33}{i} = '**';
%         data{32}{i} = '0.00T';
%     end
% end
% 
% counter = 1;
% i = 1;
% while i <= length(data{1})
%     datestring = data{3}{i};
%     minutes = datestring(11:12);
%     pres = str2double(data{24}{i});
%     alt = str2double(data{25}{i});
%     stp = str2double(data{26}{i});
%     if strcmp(minutes, minuteinterval)
%         % Process the line into metars
%         if str2double(minutes) >= 50
%             minutes = '00';
%             datestring = [datestring(1:8) ' ' datestring(9:10) ':' minutes];
%             serialdate = datenum(datestring, 'yyyymmdd HH:MM') + (1/24);
%         else
%             datestring = [datestring(1:8) ' ' datestring(9:10) ':' minutes];
%             serialdate = datenum(datestring, 'yyyymmdd HH:MM');
%         end
%         
%         metarStruct(counter).date = serialdate;
%         metarStruct(counter).temp = (5/9)*(str2double(data{22}{i}) - 32);
%         metarStruct(counter).maxtemp = (5/9)*(str2double(data{27}{i}) - 32);
%         metarStruct(counter).mintemp = (5/9)*(str2double(data{28}{i}) - 32);
%         metarStruct(counter).dewpt = (5/9)*(str2double(data{23}{i}) - 32);
%         metarStruct(counter).pres = pres;
%         metarStruct(counter).alt = alt;
%         metarStruct(counter).stp = stp;
%         if isnan(metarStruct(counter).pres) && ~isnan(metarStruct(counter).stp)
%             metarStruct(counter).pres = gen_calculate_SLP(metarStruct(counter).temp, ...
%                 metarStruct(counter).dewpt, metarStruct(counter).stp, ...
%                 metarStruct(counter).alt);
%         end
%         
%         metarStruct(counter).wdir = str2double(data{4}{i});
%             % wdir = 990 means variable winds. NaN means calm wind.
%         metarStruct(counter).wspd = str2double(data{5}{i}) * 0.44704; % mph to m/s
%         metarStruct(counter).gust = str2double(data{6}{i}) * 0.44704; % mph to m/s
%         metarStruct(counter).relhum = gen_calculate_RH(metarStruct(counter).temp, ...
%             metarStruct(counter).dewpt); % Include sub-function for RH calc
%         % Check for trace amounts in precip reports.
%         if strcmp(data{29}{i}, '0.00T')
%             metarStruct(counter).precip1 = -1;
%         else
%             metarStruct(counter).precip1 = str2double(data{29}{i}) * 25.4; % Convert inches to mm
%         end
%         if strcmp(data{30}{i}, '0.00T')
%             metarStruct(counter).precip6 = -1;
%         else
%             metarStruct(counter).precip6 = str2double(data{30}{i}) * 25.4; % inches to mm
%         end
%         if strcmp(data{31}{i}, '0.00T')
%             metarStruct(counter).precip24 = -1;
%         else
%             metarStruct(counter).precip24 = str2double(data{31}{i}) * 25.4; % inches to mm
%         end
%         metarStruct(counter).snow = str2double(data{33}{i});
%         
%         counter = counter + 1;
%     else
%         % Check if the minute interval is changing to a different one and
%         % update as such. Otherwise, continue through the loop. The method
%         % to check if the minute interval has changed will be to see if the
%         % new minute interval occurs at least 7 more times in less than the
%         % next 15 lines.
%         temp_i = i + 1;
%         countintervals = 0;
%         newinterval = 0;
%         if i + 15 > length(data{3})
%             temp_i = i + 16; % This will make the while loop not run so
%                              % we don't get an index exeeds dimensions
%                              % error.
%         end
%         while temp_i <= i + 15 && ~newinterval
%             m = data{3}{temp_i}(11:12);
%             if strcmp(m, minutes)
%                 countintervals = countintervals + 1;
%             end
%             if countintervals == 7
%                 newinterval = 1;
%                 minuteinterval = minutes;
%                 i = i - 1;
%             end
%             temp_i = temp_i + 1;
%         end
%         clear temp_i countintervals newinterval m
%     end
%     i = i + 1;
% end
% fprintf('complete.\n')
% 
% if savefilepath ~= 0
%     fprintf('Saving Matlab struct to specified file...')
%     save(savefilepath, 'metarStruct')
%     metarStruct = 1;
% else
%     return
% end
% fprintf('complete.\n')
% fclose('all');
% 
% end

