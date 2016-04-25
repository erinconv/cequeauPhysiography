%% creates (I,J) positioning raster
function [iCP jCP iCE jCE CElist]=doCEcoordinates(CEgrid,idCE)
%DOCECOORDINATES Extracts the i and j coordinates for all CEs and CPs
%   Uses the CEgrid raster and the idCE vector generated by redoCEgrid.m
%   function to assign i,j coordinates to each CE and CP within the
%   watershed.  Starts at 10,10 in case of weather stations outside of the
%   watershed
%
%   [iCP jCP iCE jCE CElist]=doCEcoordinates(CEgrid,idCE)
%
%   Input:  'CEgrid'        - CEgrid raster. Same dimensions as FAC/CAT/DEM rasters.
%           'idCE'          - The ID of the CE in which each CP is contained (essentially a new version of 'containingCE' variable)
%          
%   Output: 'iCP'          - Vector of i coordinates for CPs
%           'jCP'          - Vector of j coordinates for CPs
%           'iCE'          - Vector of i coordinates for CEs
%           'jCE'          - Vector of i coordinates for CEs
%           'CElist'        - Vector of CEs sorted by (i,j) coordinate (sorted first based on i and then based on j)
%           
%   By Stephen Dugdale, 2015-05-07

%sum CE grid to create two vectors that show where CE changes
CEgridX=sum(CEgrid,1);
CEgridY=flipud(sum(CEgrid,2));

%with this bit of the code, we want to renumber the vectors so that they form the indexes for the (i,j) numbering of the CEs (from 10 upwards)

%first, renumber the x-vector
currentValue=CEgridX(1); %set intial 'currentValue'
j=10; %set increment to 10
for n=1:numel(CEgridX); %scan along vector one cell at a time
    if CEgridX(n)==0
       CEgridX(n)=NaN;
       continue
    end
    
    if CEgridX(n)==currentValue; %if the value of the cell is the same as 'currentValue', we must still be in the same (Ith) CE...
       CEgridX(n)=j; %...therefore, set the Nth cell to 'j'...
       %currentValue=CEgridX(n); %...and set the new current value equal to this cell.
    else %if the cell value HAS changed (compared to 'currentValue'), we must have changed cell...
       currentValue=CEgridX(n); %...therefore, set a new 'currentValue', based on the value of the new cell
       j=j+1; %up the increment by one, because we must be in a new cell 
       CEgridX(n)=j; %set the value of the new cell to this new increment
    end
end
CEgridX=CEgridX-(nanmin(CEgridX)-10);
    
%repeat the exact same process for the y-vector
currentValue=CEgridY(1);
j=10;
for n=1:numel(CEgridY);
    if CEgridY(n)==0
       CEgridY(n)=NaN;
       continue
    end
        
    if CEgridY(n)==currentValue;
       CEgridY(n)=j;

    else
       currentValue=CEgridY(n); 
       j=j+1;
       CEgridY(n)=j;
    end
end
CEgridY=CEgridY-(nanmin(CEgridY)-10);

CEgridX=CEgridX'; %convert CEgridX to column vector
CEgridY=flipud(CEgridY); %flip CEgridY upside down because of the way Matlab treats Y axis in rasters

%get CE (i,j) positions
h = waitbar(0,'Getting (I,J) for CEs...');
for n=1:max(idCE); %loop through CEs 
    [row col]=find(CEgrid==n); %get location of Nth CE
    iCE(n,1)=mode(CEgridX(col)); %find i coordinate of Nth CE
    jCE(n,1)=mode(CEgridY(row)); %find j coordinate of Nth CE
    waitbar(n / max(idCE));%update waitbar
end
close(h);

%get CP (i,j) positions
iCP=iCE(idCE); %get i coordinate of CP
jCP=jCE(idCE); %get j coordinate of CP

%sort iCE and jCE vectors
CElist=(1:max(idCE))'; %create vector of CE index
%out=sortrows([iCE,jCE,CElist],[1 2]); %sort the i,j and index coordinates based on the [i,j] coordinates
%iCE=out(:,1);
%jCE=out(:,2);
%CElist=out(:,3);

end