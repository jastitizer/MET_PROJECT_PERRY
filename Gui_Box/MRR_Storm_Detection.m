function [ MRR , date_range ] = MRR_Storm_Detection( MRR, settings )
%MRR_STORM_DETECTION Finds storms in an MRR struct generated by simp2matrix
%
%   SUMMARY: This function takes in a structure that holds MRR data. This
%   function in particular utilizes the dBZ values. There are a few
%   different algorithms used in this function. The combination of them
%   yields an accurate determination of when storms occur.
%
%   INPUTS:
%     - MRR_struct: Structure of MRR data that is of the same form given
%       by the MRR_simp2matrix function. 
%     - settings: Any other information that the function needs will be
%       given in this structure. Current fields involved in settings are
%       listed below.
%         - Z_threshhold: The threshhold value that is used to detect the
%           "maximum" of a storm.
%         - Z_threshhold_2: The threshhold value that is used to detect the
%           "edges" of a storm.
%         - rows_per_day: The amount of Z measurements in one day of
%           measurements. This information is useful when running data over
%           multiple days/weeks. THIS FIELD MUST BE PROVIDED IN ORDER TO
%           RUN THE FUNCTION.
%
%   OUTPUTS:
%     - foundStorm: Returns 1 if a storm is found. Otherwise, 0.
%     - date_range: A structure of the date ranges in serial form, given by
%       the fields 'start' and 'end'
%
%   Author: Spencer Rhodes
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA FILTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sets dBZ values that are less than 0 or greater than 75 to NaN.

% Checks if data provided includes second MRR (for Alta processing)
if isfield(settings, 'MRR2')
    MRR1 = MRR; clear MRR
    MRR2 = settings.MRR2;
    
    MRR.header = MRR1.header;
    MRR1.Z = MRR1.Z(:,6:20);
    MRR1.W = MRR1.W(:,6:20);
    MRR1.SW = MRR1.SW(:,6:20);
    counter = length(MRR1.Z(1,:));
    i = 1;
    while counter
        MRR1.Z = [MRR1.Z(:,1:i-1), repmat(MRR1.Z(:,i),1,6), MRR1.Z(:,i+1:end)];
        MRR1.W = [MRR1.W(:,1:i-1), repmat(MRR1.W(:,i),1,6), MRR1.W(:,i+1:end)];
        MRR1.SW = [MRR1.SW(:,1:i-1), repmat(MRR1.SW(:,i),1,6), MRR1.SW(:,i+1:end)];
        i = i + 6;
        counter = counter - 1;
    end
    MRR.dates = MRR1.dates;
    MRR.Z = [MRR2.Z(:,1:30), MRR1.Z];
    MRR.W = [MRR2.W(:,1:30), MRR1.W];
    MRR.SW = [MRR2.SW(:,1:30), MRR1.SW];
%     echoTopFilterStart = 121;
    
% Checks if data provided is from Alta
elseif isfield(settings, 'is_alta')
    MRR.Z = MRR.Z(:,1:21);
    MRR.W = MRR.W(:,1:21);
    MRR.SW = MRR.SW(:,1:21);
%     echoTopFilterStart = 22;
    
% Use to cut the top off of the data
elseif isfield(settings, 'choptop')
    MRR.Z = MRR.Z(:,1:24);
    MRR.W = MRR.W(:,1:24);
    MRR.SW = MRR.SW(:,1:24);
end

filter_low = MRR.Z < -5;
if isfield(settings, 'miami')
    filter_high = MRR.Z > 50;
else
    filter_high = MRR.Z > 45;
end

filter = filter_low | filter_high;

MRR.Z(filter) = NaN;

%%%%%%%% FIND STORMS USING AVERAGE IN A COLUMN ACROSS TIMES METHOD %%%%%%%%

% Initialize Constants:
MIN_T_BETWEEN_STORMS = 2/24; % Feel free to change. Default is 6.
MAX_T_DISSIPATION = 1/24; % Feel free to change. Default is 3.

date_range = struct([]);

% Set the dBZ_threshhold to user input if given. Otherwise, default to 10.
if isfield(settings, 'Z_threshhold')
    Z_threshhold = settings.Z_threshhold;
else
    Z_threshhold = 10;
end

% This is a secondary dBZ threshhold value that is used when searching for
% the edges of a storm.
if isfield(settings, 'Z_threshhold_2')
    Z_threshhold_2 = settings.Z_threshhold_2;
else
    Z_threshhold_2 = Z_threshhold * (2/3);
end

% reset_columnsAvg will set columnsAvg back to zero after 15 minutes, or if
% rounding is an issue, then it will set back to zero after the closest
% amount of rows that would yield a 15 minute interval.
if isfield(settings, 'rows_per_day')
    reset_columnsAvg = int8(settings.rows_per_day / 96);
else
    reset_columnsAvg = 15; % Assumes that the measurements are per minute.
end

if reset_columnsAvg == 1
    reset_columnsAvg = reset_columnsAvg + 1;
end

% Set rows and cols of dBZ values in MRR_struct.
rows = length(MRR.Z);

%%% EXPERIMENTAL %%%
% Perform echo top correction for Alta, UT. This involves examining the
% column at each time to determine if the echo top (beginning gate 21/22 in
% 150 gate MRR; 121 gate in combined MRR)
% if isfield(settings, 'is_alta') || isfield(settings, 'MRR2')
%     
% nanZarray = isnan(MRR.Z);
% fprintf('Alta echo top correction...');
% for n = 1:rows
%     if n == 3228
%         stop = 1;
%     end
%     If there is at least one non-Nan in the echo top...
%     if sum(nanZarray(n, echoTopFilterStart:end) ~= 1)
% 
%         If there is at least one NaN in the echo top (i.e. if the entire echo
%         top has Z values, then the echo top is probably legitimate)...
%         if sum(nanZarray(n, echoTopFilterStart:end) == 1)
% 
%             If the column below the echo top is all NaN...
%             if nanZarray(n, 1:echoTopFilterStart-1)
% 
%                 MRR.Z(n, echoTopFilterStart:end) = NaN;
% 
%             If the column below is not all NaN, want to find out how many
%             gates between echo top and echo below are NaN. If the amount of
%             gates is 2 or more, we'll say that is sufficient to remove the
%             echo top
%             elseif sum(nanZarray(find(nanZarray(n, 1:echoTopFilterStart) == 0, 1, 'last'):...
%                                  find(nanZarray(n, echoTopFilterStart:end) == 0, 1, 'first')...
%                                  -1+echoTopFilterStart)) > 1
% 
%                 MRR.Z(n, find(nanZarray(n, 1:echoTopFilterStart) == 0, 1, 'last'):end) = NaN;
% 
%             end
%         end
%     end
% end
% fprintf('done.\n');
% 
% end

% Declares a new array that copies the dBZ data from the MRR_struct but
% does not copy the first column of dates. UPDATE 10/3/14: No longer
% necessary since dates is in a separate struct. However, first gate was
% always NaNs anyway, so changing this now doesn't matter
array_of_Z = MRR.Z;    

% This is a time associated value that is used to determine where the edge
% of a storm is. If the seperate column averages are less than the
% secondary dBZ threshhold for at least as long as the max_time_since_storm,
% then the first column that was below the secondary dBZ threshhold marks the
% edge of the storm.
max_time_since_storm = reset_columnsAvg * 2;

% Calculate the average of the dBZ at each height for every time in the data.
colAvg = nanmean(array_of_Z, 2);

% Checks for storms using a "column averages" algorithm. 'count' tracks the
% number of storms that have been found.
count = 0;
i = 0;

fprintf('Detecting storms...')
while i < rows
    i = i + 1;
        
    % If the average of the next column exceeds the threshhold...
    if (colAvg(i) >= Z_threshhold)
        remember_row = i;
        temp_i = i;
        
        % Determines at which time (row) the column average goes below
        % the secondary dBZ threshhold value. Then counts the number of
        % consecutive rows after that are below the secondary dBZ threshhold
        % value. If 30 minutes worth of data is below the secondary dBZ
        % threshhold value, then the time (row) that started the counting
        % is the beginning of the storm.
        time_since_storm = 0;
        remember_storm = temp_i;
        while time_since_storm < max_time_since_storm && temp_i > 1
            if  time_since_storm == 0 && colAvg(temp_i) < Z_threshhold_2
                remember_storm = temp_i;
                time_since_storm = time_since_storm + 1;
            elseif colAvg(temp_i) < Z_threshhold_2
                time_since_storm = time_since_storm + 1;
            elseif isnan(colAvg(temp_i))
                time_since_storm = time_since_storm + 1;
            else
                time_since_storm = 0;
            end
            temp_i = temp_i - 1;
        end
        
        % Set date start to equal the last column that was above the
        % secondary dBZ threshhold. If no column found, then it will be
        % the first time in the time series.
        if temp_i == 1
            start.date = MRR.dates(temp_i);
            start.row = temp_i;
        else
            start.date = MRR.dates(remember_storm);
            start.row = remember_storm;
        end
        
        % Set columns average and start traversing again from the row
        % that first yielded a column average above the dBZ threshhold
        columnsAvg = colAvg(remember_row);
        
        % Set temp_i value to the row that first encountered a column
        % average above the dBZ threshhold and create a counter for 
        % calculating averages after the new temp_i value.
        temp_i = remember_row;
        avg_counter = 1;
        
        % Determines at which time (row) the average of the columns
        % starting from the temp_i row is less than the dBZ threshhold.
        % Resets averaging the columns every 15 minutes.
        while (columnsAvg >= Z_threshhold) && (temp_i < rows)
            temp_i = temp_i + 1;
            numerator = columnsAvg * avg_counter;
            avg_counter = avg_counter + 1;
            columnsAvg = (numerator + colAvg(temp_i)) / avg_counter;
        end
        
        % If the end of the data was reached before the columnsAvg went
        % below the dBZ threshhold, make the last time in the time series the
        % end time for the storm.
        if temp_i == rows
            endt.date = MRR.dates(temp_i);
            endt.row = temp_i;
        else
            temp_i = temp_i + 1;
            time_since_storm = 0;
            remember_storm = temp_i;

            % Similar algorithm to the while loop that checks to see where
            % the storm begins. In contrast, this while loop searches for
            % the values such that 30 minutes later no column average has
            % been higher than the secondary dBZ threshhold.
            while time_since_storm < max_time_since_storm && temp_i < rows
                if time_since_storm == 0 && colAvg(temp_i) < Z_threshhold_2
                    remember_storm = temp_i;
                    time_since_storm = time_since_storm + 1;
                elseif colAvg(temp_i) < Z_threshhold_2
                    time_since_storm = time_since_storm + 1;
                elseif isnan(colAvg(temp_i))
                    time_since_storm = time_since_storm + 1;
                else
                    time_since_storm = 0;
                end
                temp_i = temp_i + 1;
            end
            
            endt.date = MRR.dates(remember_storm);
            endt.row = remember_storm;
        end
        
        % Insert found dates into date_range structure that is returned
        % from function. foundStorm count increased because a storm was 
        % found.
        if count == 0
            count = count + 1;
        end
        
        % If there is at least one storm in the date_range, then check if
        % the previous storm's start time is the same as the current
        % detected storm's start time. If both are true, then make the
        % previous storm's end time the current detected storm's end time.
        if count > 1 && date_range(count - 1).start == start.date
            date_range(count - 1).end = endt.date;
            date_range(count - 1).row_end = endt.row;
        else
            date_range(count).start = start.date;
            date_range(count).row_start = start.row;
            date_range(count).end = endt.date;
            date_range(count).row_end = endt.row;
            count = count + 1;
        end
                
        % Set i to be the row that the last detected storm ended on. This
        % is done to improve the function's efficiency by avoiding
        % re-detecting storms.
        i = endt.row;
    end
end

% Number of storms in the date_range.
max_dates = length(date_range);
count = 1;

% Determines if any of the storms detected last shorter than 15 minutes. If
% so, delete the storm from the 'date_range' because it is not "worth
% detecting."
while count < max_dates
    time_dif = date_range(count).row_end - date_range(count).row_start;
    if time_dif <= int32(settings.rows_per_day / 96)
        date_range(count) = [];
        count = count - 1;
        max_dates = max_dates - 1;
    end
    count = count + 1;
end

% Now error check the date ranges to look for small storms that belong
% together as one storm.
count = length(date_range);
if count > 1
    j = 2;
    
    % Executes as long as the counter 'j' is less than the number of dates
    % in the date_range. The count is adjusted if two dates are merged, and
    % the counter 'j' is decreased as well to account for the adjustment.
    while j <= count
        
        time_dif = date_range(j).start - date_range(j - 1).end;
        dur_1 = date_range(j-1).end - date_range(j-1).start;
        dur_2 = date_range(j).end - date_range(j).start;
        
        if time_dif <= MIN_T_BETWEEN_STORMS && dur_1 + dur_2 + time_dif <= 1
            date_range(j - 1).end = date_range(j).end;
            date_range(j - 1).row_end = date_range(j).row_end;
            date_range(j) = [];
            count = count - 1;
            j = j - 1;
        elseif time_dif <= MIN_T_BETWEEN_STORMS
            if dur_1 < dur_2
                date_range(j-1).row_end = date_range(j).row_start - ...
                    (settings.rows_per_day / 24);
                date_range(j-1).end = MRR.dates(date_range(j-1).row_end);
            else
                date_range(j).row_start = date_range(j-1).row_end + ...
                    (settings.rows_per_day / 24);
                date_range(j).start = MRR.dates(date_range(j).row_start);
            end
        end
        j = j + 1;
    end
end


%%%%%%%%%%%%%%%%% ADVANCED DISSIPATION DETECTION ALGORITHM %%%%%%%%%%%%%%%%
% This algorithm detects "dissipation" in storms. That is to say, this
% algorithm will be able to notice small anomalies in the dBZ values just
% after a storm appears to have ended. This algorithm is much more
% elaborate than the algorithms used to detects the edges of the storms
% during the initial storm detection.

% Time value that represents four hours. This value is used to keep track of
% how far to keep looking from the edge of the storm.
max_time_since_storm = int32(settings.rows_per_day * MAX_T_DISSIPATION);

% Time values that represents 5 minutes. Used as a threshhold for tracking
% the "dissipations."
max_dissipitation_dur = int32(settings.rows_per_day / 288);

% Number of storms in the date_range.
max_dates = length(date_range);

% If there's more than one storm in the date_range...
if max_dates > 1
    % Keeps track of the number of storms.
    counter = 1;
    
    % Loops through as long as there are more storms/dates in the
    % date_range.
    while counter <= max_dates
        
        % Tracks the duration of any dissipation that there may be before
        % or after the storm.
        dissipation_duration = 0;
        
        % Tracks the time searching from the current edge of the storm.
        % If a dissipation is found, meaning that there is a five minute
        % interval within three hours of the beginning or end of the storm,
        % then this counter will go back to zero and resume counting again
        % from the new edge of the storm, the end of the dissipation just
        % encountered.
        time_since_storm = 0;
        
        % Boolean representation that equals 1 if the algorithm is looking
        % at a dissipation and still determining where it ends.
        is_searching = 0;
        
        % Boolean representation that equals 1 if a new edge of the storm is
        % found due to dissipation.
        new_edge_found = 0;
        
        % Sets the temp_i value to the current date's start row.
        temp_i = date_range(counter).row_start;
        
        % This variable needed to be initialized before the while loop. It
        % is set to the number of rows in the data set of dBZ because it is
        % not possible for a storm to start at the last time in the data
        % set.
        edge_of_storm = rows;
        
        % Executes while the time searching for the storm does not exceed 3
        % hours. If the algorithm finds a dissipation pattern and is
        % looking for the end of it, the loop keeps executing. Once the end
        % of the dissipation has been found, the algorithm restarts the 3
        % hour search from the end of the dissipation. The loop will stop
        % executing no matter what if the search goes to the very beginning
        % of the data. This loop searches back in time from the start of
        % the current storm.
        while (time_since_storm < max_time_since_storm || is_searching) ...
                && temp_i > 0
            time_since_storm = time_since_storm + 1;
            if colAvg(temp_i) > Z_threshhold_2 && ~is_searching
                is_searching = 1;
                dissipation_duration = dissipation_duration + 1;
            elseif colAvg(temp_i) > Z_threshhold_2
                dissipation_duration = dissipation_duration + 1;
            elseif dissipation_duration >= max_dissipitation_dur
                edge_of_storm = temp_i;
                time_since_storm = 0;
                is_searching = 0;
                new_edge_found = 1;
                dissipation_duration = 0;
            else
                is_searching = 0;
                dissipation_duration = 0;
            end
            
            temp_i = temp_i - 1;
        end
        
        % If the current storm being examined is not the first storm in the
        % date_range struct, then check if the new 'edge_of_storm' value
        % found is less than or equal to the previous storm's end row. If
        % both are true, that means that the storms overlap. Therefore, the
        % previous storm's end time is set to the current storm's end time
        % and the current storm is removed from the 'date_range'.
        if counter > 1 && edge_of_storm <= date_range(counter - 1).row_end
            date_range(counter - 1).end = date_range(counter).end;
            date_range(counter - 1).row_end = date_range(counter).row_end;
            date_range(counter) = [];
            counter = counter - 1;
            max_dates = max_dates - 1;
            new_edge_found = 0;
        end
        
        % If a new edge is found, change the start of the storm. This will
        % NOT execute if the previous if statement is executed.
        if new_edge_found
            date_range(counter).start = MRR.dates(edge_of_storm);
            date_range(counter).row_start = edge_of_storm;
        end
        
        % Reset these values to zero for checking the end of the storm.
        dissipation_duration = 0;
        time_since_storm = 0;
        is_searching = 0;
        new_edge_found = 0;
        
        % Sets the temp_i valueto the current date's end row.
        temp_i = date_range(counter).row_end;
        
        % Set to zero because it is not possible for a storm to end at the
        % beginning of the data set.
        edge_of_storm = 0;
        
        % Same as the previous while loop, except searches for dissipations
        % starting from the end of the storm, looking forward in time.
        while (time_since_storm < max_time_since_storm || is_searching) ...
                && temp_i <= rows
            time_since_storm = time_since_storm + 1;
            if colAvg(temp_i) > Z_threshhold_2 && ~is_searching
                is_searching = 1;
                dissipation_duration = dissipation_duration + 1;
            elseif colAvg(temp_i) > Z_threshhold_2
                dissipation_duration = dissipation_duration + 1;
            elseif dissipation_duration >= max_dissipitation_dur
                time_since_storm = 0;
                edge_of_storm = temp_i;
                is_searching = 0;
                new_edge_found = 1;
                dissipation_duration = 0;
            else
                is_searching = 0;
                dissipation_duration = 0;
            end
            
            temp_i = temp_i + 1;
        end
        
        % If the current storm being examined is not the last storm in the
        % date_range struct, then check if the new 'edge_of_storm' value
        % found is greater than or equal to the next storm's start row.
        % If both are true, that means that the storms overlap. Therefore, 
        % the next storm's start time is set to the current storm's start
        % time and the current storm is removed from the 'date_range'.
        if counter < max_dates && edge_of_storm >= date_range(counter + 1).row_start
            date_range(counter + 1).start = date_range(counter).start;
            date_range(counter + 1).row_start = date_range(counter).row_start;
            date_range(counter) = [];
            counter = counter - 1;
            max_dates = max_dates - 1;
            new_edge_found = 0;
        end
        
        % If a new edge is found, change the start of the storm. This will
        % NOT execute if the previous if statement is executed.
        if new_edge_found
            date_range(counter).end = MRR.dates(edge_of_storm);
            date_range(counter).row_end = edge_of_storm;
        end
        
        counter = counter + 1;
    end
    
end
%%%%%%%%%%%%% END OF ADVANCED DISSIPATION DETECTION ALGORITHM %%%%%%%%%%%%%

% Now error check the date ranges to look for small storms that belong
% together as one storm.
count = length(date_range);
if count > 1
    j = 2;
    
    % Executes as long as the counter 'j' is less than the number of dates
    % in the date_range. The count is adjusted if two dates are merged, and
    % the counter 'j' is decreased as well to account for the adjustment.
    while j <= count
        
        time_dif = date_range(j).start - date_range(j - 1).end;
        dur_1 = date_range(j-1).end - date_range(j-1).start;
        dur_2 = date_range(j).end - date_range(j).start;
        
        if time_dif <= 0.2500 && dur_1 + dur_2 + time_dif <= 1
            date_range(j - 1).end = date_range(j).end;
            date_range(j - 1).row_end = date_range(j).row_end;
            date_range(j) = [];
            count = count - 1;
            j = j - 1;
        elseif time_dif <= 0.2500
            if dur_1 < dur_2
                date_range(j-1).row_end = date_range(j).row_start - ...
                    (settings.rows_per_day / 24);
                date_range(j-1).end = MRR.dates(date_range(j-1).row_end);
            else
                date_range(j).row_start = date_range(j-1).row_end + ...
                    (settings.rows_per_day / 24);
                date_range(j).start = MRR.dates(date_range(j).row_start);
            end
        end
        j = j + 1;
    end
    
    % After the above loop is done, run another loop that will remove
    % storms from the date_range list if the storm is shorter than 5 and a
    % half hours and has greater than or equal to 80% NaN values in that
    % time span.
    
    % Start from the back of the date_range list.
    j = length(date_range);
    while j > 0
        curstorm = MRR.Z(date_range(j).row_start:date_range(j).row_end,:);
        if length(curstorm) < 330 && sum(sum(isnan(curstorm))) / numel(curstorm) >= 0.8
            date_range(j) = [];
        end
        j = j - 1;
    end
end

% Add 30 minutes to the beginning and end of each storm in order to buffer
% the edges for better viewing of imagesc plots.
for i = 1:length(date_range)
    rowdif = settings.rows_per_day / 48;
    if date_range(i).row_start <= rowdif
        % Do nothing
    else
        date_range(i).start = date_range(i).start - (1/48);
        date_range(i).row_start = date_range(i).row_start - rowdif;
    end
    if (date_range(i).row_end + rowdif) > rows
        % Do nothing
    else
        date_range(i).end = date_range(i).end + (1/48);
        date_range(i).row_end = date_range(i).row_end + rowdif;        
    end
end

% Check for storms that are longer than 23 hours. If a storm is found, then
% begin searching to the left and right of the center of the storm for a
% period of at least [ONE HOUR] that there is no registered reflectivity
% (all colAvgs are less than the Z_threshhold_2. If no gap is found, then
% display a message telling the user at what index there is a storm that is
% too large ( > 23 hours).
i = 1;
max_gap = settings.rows_per_day / 24;
max_storm_size = settings.rows_per_day - (settings.rows_per_day / 24);
while i <= length(date_range)
    
    if date_range(i).row_end - date_range(i).row_start >= max_storm_size

        startindex = round((date_range(i).row_end + date_range(i).row_start) / 2);
        firstgap_left = 1;
        firstgap_right = 1;
        remember_left = 0;
        index_left = startindex - 1;
        remember_right = 0;
        index_right = startindex;
        count_left = 0;
        count_right = 0;
        foundgap_left = 0;
        foundgap_right = 0;
        foundgap_center = 0;

        while ~foundgap_left && ~foundgap_right && ~foundgap_center && ...
                index_left >= date_range(i).row_start && ...
                index_right <= date_range(i).row_end
            if colAvg(index_left) < settings.Z_threshhold_2
                if count_left == 0
                    remember_left = index_left;
                end
                count_left = count_left + 1;
            else
                if firstgap_left == 1
                    firstgap_left = 0;
                end
                count_left = 0;
            end
            if colAvg(index_right) < settings.Z_threshhold_2
                if count_right == 0
                    remember_right = index_right;
                end
                count_right = count_right + 1;
            else
                if firstgap_right == 1
                    firstgap_right = 0;
                end
                count_right = 0;
            end
            
            if firstgap_left && firstgap_right && ...
                    count_left + count_right >= max_gap
                foundgap_center = 1;
            end
            if count_left >= max_gap
                foundgap_left = 1;
            end
            if count_right >= max_gap
                foundgap_right = 1;
            end
            
            index_left = index_left - 1;
            index_right = index_right + 1;
        end
        index_left = index_left + 1;
        index_right = index_right - 1;
        
        index_split = 0;
        if foundgap_center
            index_split = round((index_left + index_right) / 2);
        elseif foundgap_left
            index_split = round((index_left + remember_left) / 2);
        elseif foundgap_right
            index_split = round((index_right + remember_right) / 2);
        end
        
        if foundgap_center || foundgap_right || foundgap_left
            newdate.row_start = index_split;
            newdate.row_end = date_range(i).row_end;
            date_range(i).row_end = newdate.row_start;
            date_range(i).end = MRR.dates(date_range(i).row_end);
            newdate.start = MRR.dates(newdate.row_start);
            newdate.end = MRR.dates(newdate.row_end);
            date_range = [date_range(1:i), newdate, date_range((i+1):end)];
            i = i - 1;
        else
            fprintf('\nStorm at index %d is longer than 23 hours and can not be automatically separated.',i)
        end

    end
    
    i = i + 1;
end



fprintf('\ncomplete.\n')
                
                
end