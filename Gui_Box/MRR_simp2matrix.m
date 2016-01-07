function [MRR ] = MRR_simp2matrix(fullfilepath,forced_gate_count,records_per_file)
%MRR_SIMP2MATRIX Summary of this function goes here
% INFO
%     Function: MRR_simp2matrix
%     Syntax: >> MRR_simp2matrix(single_MRR_.simp_filepath)
%     Creator: Andrew Hall
%     Date: July 30, 2010
%     Revised: August 17, 2010 to better determine gate count.
%     
% SUMMARY
%     This function reads in a .simp.MRR.asc file and stores it into a
%     structure for further processing.  If the file does not exist a
%     placeholder structure is created.  The structure output is detailed
%     below.  It will always generate a structure with at least 1440
%     records, if the input file has less than NaN records are created.
% 
% INPUTS - (1+2)
%     fullfilepath: This is the full filepath to the .simp file.  If the
%     function can not find the file IT WILL CREATE NAN DATA.  IF YOU HAVE
%     A BUNCH OF NANs THIS IS PROBABLY WHY.
%
%     forced_gate_count - integer (of type double) - value that is the
%     number of gates in the MRR file.  If you don't include this it will
%     default to 31.  ***This could be improved***
%
%     records_per_file - integer ( of type double) - integer value of
%     number of records per file.  ***this could be improved***
%     
% OUTPUTS - (1)
%     This program outputs an MRR structure variable with the following
%     components:
%     MRR.Z: This is an array of Z values from the file.  It is 1440 records
%     long, one for each minute in the day.  It is the width of the number of
%     gates in the file + 1, with the first column being the matlab datenumber
%     
%     MRR.W: Same as MRR.Z but with W values
%     
%     MRR.rawHeaderLines: These are the first four lines of text from the MRR
%     file, stored in a cell array.
%     
%     MRR.header contains the values from the header data at the beginning of
%     each record.  See C3P website for details
%     
% COMMENTS
%     None
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

%Open file and clear Z and W
% MRRFile=fopen(fullfilepath);
% for k = 1:4, fgetl(MRRFile); end
% first = fgetl(MRRFile);
% second = fgetl(MRRFile);
% if strcmp(first(16:17),second(16:17))
%     records_per_file = 2880;
% else
%     records_per_file = 1440;
% end
% fclose('all'); clear MRRFile k line
MRRFile=fopen(fullfilepath);

if nargin == 2
    numGates = forced_gate_count;
    records_per_file = 1440;
else
    numGates = 31;
end    


%This checks to see if it opened a file, if it doesn't it creates a dummy
%array of NaNs with the proper amount of entries.  This is so that
%comparison functions can see that there wasn't a file.  It is effectively
%a place holder
if MRRFile == -1;
    MRR.Z =nan(records_per_file,numGates);
    MRR.W = nan(records_per_file,numGates);
    MRR.SW = nan(records_per_file,numGates);
    MRR.rawHeaderLines = 'No File';
        
    [~, date, ~] = fileparts(fullfilepath);
    date = regexp(date,'\d+', 'match');
    date = datenum(date,'yyyymmdd');
    
    dateincrements = date:1/records_per_file:date+1;
    MRR.dates = dateincrements(1:records_per_file)';
    
    MRR.header.numgates = numGates;
    [MRR.header.year, MRR.header.month, MRR.header.day, MRR.header.hour, MRR.header.minute, MRR.header.second] = datevec(date);
    return;
end

%reads in raw headerlines and then rewinds so that the fileposition is
%reset
MRR.rawHeaderLines = textscan(MRRFile, '%[^\n]', 4);
frewind(MRRFile);
%Scans file, skipping the 4 headerlines
rawMRR=textscan(MRRFile, '%[^\n]', 'HeaderLines', 4);

rawMRR = rawMRR{1};

mrrInfo = str2num(char(rawMRR{1}));
MRR.header.year = mrrInfo(1);
MRR.header.month = mrrInfo(2);
MRR.header.day = mrrInfo(3);
MRR.header.hour = mrrInfo(4);
MRR.header.minute = mrrInfo(5);
MRR.header.second = mrrInfo(6);
MRR.header.height = mrrInfo(7);
MRR.header.numgates = mrrInfo(8);
MRR.header.firstgate = mrrInfo(9);
MRR.header.gatedist = mrrInfo(10);
MRR.dates = nan(length(rawMRR),1);
MRR.Z = nan(length(rawMRR),MRR.header.numgates);
MRR.W = nan(length(rawMRR),MRR.header.numgates);
MRR.SW = nan(length(rawMRR),MRR.header.numgates);


for i = 1:length(rawMRR)
    fileline = str2num(char(rawMRR{i}));
    serialdate = datenum([fileline(1), fileline(2), fileline(3), fileline(4), fileline(5), fileline(6)]);
    fileline = fileline(11:end);
    MRR.dates(i) = serialdate;
    MRR.Z(i,:) = fileline(1:MRR.header.numgates);
    MRR.W(i,:) = fileline(MRR.header.numgates+1:MRR.header.numgates*2);
    try
        MRR.SW(i,:) = fileline(MRR.header.numgates*2+1:MRR.header.numgates*3);
    catch error
        if ~isempty(strfind(error.message, 'Index exceeds matrix dimensions'))
            if isfield(MRR, 'SW')
                MRR = rmfield(MRR, 'SW');
            end
        end
    end
end

%convert MRR missing values into NaN for MATLAB
MRR.Z(MRR.Z == -99999.9) = NaN;
MRR.W(MRR.W == -99999.9) = NaN;
if isfield(MRR, 'SW')
    MRR.SW(MRR.SW == -99999.9) = NaN;
end


%This enforces the 1440 record minimum that is needed to maintain standards
%between files.  If the file is less than 1440 elements it creates a dummy
%and inserts the read in records into their closest position.  Note that
%this destroys the "second" accuracy of the MRR, but since the records are
%always on the minute +- 1 second this should be acceptable.
if length(rawMRR) < records_per_file
    fulldayZ = datenum([MRR.header.year, MRR.header.month, MRR.header.day]);
    fulldayZ = fulldayZ:1/records_per_file:fulldayZ+(records_per_file-1)/records_per_file;
    fulldayZ = [fulldayZ', nan(length(fulldayZ'),MRR.header.numgates)];
    fulldayW = fulldayZ;
    if isfield(MRR, 'SW')
        fulldaySW = fulldayZ;
    end
    
    for minute = 1:length(rawMRR)
        [~, index, ~] = gen_find_closest_single(MRR.Z(minute,1),fulldayZ(:,1));
        fulldayZ(index,:) = MRR.Z(minute,:);
        fulldayW(index,:) = MRR.W(minute,:);
        if isfield(MRR, 'SW')
            fulldaySW(index,:) = MRR.SW(minute,:);
        end
    end
    
    MRR.Z = fulldayZ;
    MRR.W = fulldayW;
    if isfield(MRR, 'SW')
        MRR.SW = fulldaySW;
    end
end

        
        

        
        
fclose('all');
end

