function [MRRfinal] = caller_MRR_simp2matrix( directory, prefix, datestart, dateend, suffix, records_per_file )
%CALLER_MRR_SIM2MATRIX Summary of this function goes here
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



tzero = datenum(datestart, 'yyyymmdd');
tone = datenum(dateend, 'yyyymmdd');

days = (tone - tzero)+1;
numGates = 31;

pct_complete = [.1 .2 .3 .4 .5 .6 .7 .8 .9];
prev_complete = 0;

for i = 0:days-1
    
    datevar = datestr(tzero + i, 'yyyymmdd');
    fileloc = strcat(directory, prefix, datevar, suffix);
    [MRR] = MRR_simp2matrix(fileloc,numGates,records_per_file);
    if isfield(MRR, 'SW'), hasSW = 1; else hasSW = 0; end
    
    if i == 0
        MRRfinal.Z = zeros(days*records_per_file,MRR.header.numgates+1);
        MRRfinal.W = zeros(days*records_per_file,MRR.header.numgates+1);
        MRRfinal.Z(:,1) = tzero:1/records_per_file:tone+(records_per_file-1)/records_per_file;
        MRRfinal.W(:,1) = tzero:1/records_per_file:tone+(records_per_file-1)/records_per_file;
        MRRfinal.header = MRR.header;
        MRRfinal.rawHeaderLines = MRR.rawHeaderLines;
        numGates = MRRfinal.header.numgates;
        
        if hasSW
            MRRfinal.SW = zeros(days*records_per_file,MRR.header.numgates+1);
            MRRfinal.SW(:,1) = tzero:1/records_per_file:tone+(records_per_file-1)/records_per_file;
        end            
    end
    
    if isfield(MRR.header, 'gatedist') && MRRfinal.header.gatedist ~= MRR.header.gatedist
        fprintf('MRR file for %s has different gatedist than MRRfinal gatedist.\n', datevar);
    end
    

        MRRfinal.Z(i*records_per_file+1:(i+1)*length(MRR.Z),1:size(MRR.Z,2)) = MRR.Z(1:length(MRR.Z),:);
        MRRfinal.W(i*records_per_file+1:(i+1)*length(MRR.Z),1:size(MRR.Z,2)) = MRR.W(1:length(MRR.Z),:);
    
        if hasSW
            MRRfinal.SW(i*records_per_file+1:(i+1)*length(MRR.Z),1:size(MRR.Z,2)) = MRR.SW(1:length(MRR.Z),:);
        end
        
    % Display the percentage done in this loop.
    cur_complete = (i / (days-1)) >= pct_complete;
    cur_complete = find(cur_complete,1,'last');
    if pct_complete(cur_complete) ~= prev_complete
        fprintf('%d%% complete...\n', pct_complete(cur_complete) * 100)
        prev_complete = pct_complete(cur_complete);
    end
end

MRRfinal.dates = MRRfinal.Z(:,1);
MRRfinal.Z = MRRfinal.Z(:,2:end);
MRRfinal.W = MRRfinal.W(:,2:end);
MRRfinal.SW = MRRfinal.SW(:,2:end);
    
    
end

