%% Union Pacific Intermodal Terminals
% Format is UPCity_with_terminal=[latitude,longitude]
UPBarstow = [34.8780206,-116.9687861];
UPDenver = [39.7736629,-104.9614012];
UPSantaTeresa = [31.8961721,-106.7455534];
UPTucson = [32.1312589,-110.8465901];
UPLasVegas = [36.2729205,-115.0703451];
UPSaltLakeCity = [40.7495147,-112.0189125];
UPSparks = [39.5326975,-119.7560705];
UPLathrop = [37.8522909,-121.2622714];
UPOakland = [37.7983051,-122.2967888];
UPInlandEmpire =[34.0632661,-117.421382];
UPLosAngeles = [34.0093956,-118.1856459];
%% BNSF Intermodal Terminals
% Format is the same. 
BNSFAlbuquerque = [35.0488096,-106.6531909];
BNSFDenver = [39.7967548,-104.9954984];
BNSFLosAngeles = [34.0092902,-118.1915344];
BNSFOakLand = [37.800019,-122.306576];
BNSFPhoenix = [33.5151056,-112.1603732];
BNSFSanBernardino = [34.1054467,-117.3264815];
BNSFStockton = [37.905833,-121.1820203];
%% Making the CSV 
close all
% Importing the variables from some csv files made in Excel
% Since this graph is going into gephi, there are columns made 
% labels, nodetypes and intervals
WareHouseLebec_and_Stores_Labels = ESE404IKEANodestry1.Label(2:16);
WareHouseLebec_and_Stores_Nodetypes = ESE404IKEANodestry1.NodeType(2:16);
ID1=[1:length(WareHouseLebec_and_Stores_Labels)]'-1;
EmptyInterval=ESE404IKEANodestry1.Interval(2:16);
WareHouseLebec_and_Stores_Lat=ESE404IKEANodestry1.Latitude(2:16);
WareHouseLebec_and_Stores_Long=ESE404IKEANodestry1.Longitude(2:16);
WareHouseLebec_and_Stores_Lat(1)=34.9754951; %precise location of Lebec 
WareHouseLebec_and_Stores_Long(1)=-118.9475342;
% Putting all the warehouses, ports, and stores into a single table
WH = table(ID1,WareHouseLebec_and_Stores_Labels,EmptyInterval,...
    WareHouseLebec_and_Stores_Lat,WareHouseLebec_and_Stores_Long,...
    WareHouseLebec_and_Stores_Nodetypes,...
    'VariableNames',...
    {'ID' 'Label' 'Interval' 'Latitude' 'Longitude' 'Node-Type'});
%% New Store
% Adding the location of the new store (calculated in Python) to 
% this network.
NewStore = table(15,"Albuquerque Store (NM)","",35.084,-106.651,"Store",...
     'VariableNames',...
    {'ID' 'Label' 'Interval' 'Latitude' 'Longitude' 'Node-Type'});

WH=[WH;NewStore];

%% Possible new warehouse locations
% We divided possible new warehouse locations into two categories, 
% namely those near the UP and BNSF rail lines.  
% To be added to the network, they also need labels, nodetypes and
% intervals.
UP = [UPBarstow;UPDenver;UPInlandEmpire;UPLasVegas;UPLathrop;...
    UPLosAngeles;UPOakland;UPSaltLakeCity;UPSantaTeresa;UPSparks;
    UPTucson];
BNSF = [BNSFAlbuquerque;BNSFDenver;BNSFLosAngeles;BNSFOakLand;BNSFPhoenix;...
    BNSFSanBernardino;BNSFStockton];
Latitude_Longitude = [BNSF;UP];
IntermodalLabels = ["BNSFAlbuquerque","Denver Warehouse","BNSFLosAngeles",...
    "BNSFOakLand","BNSFPhoenix","BNSFSanBernardino","BNSFStockton",...
    "UPBarstow","UPDenver","UPInlandEmpire","UPLasVegas","UPLathrop",...
    "UPLosAngeles","UPOakland","UPSaltLakeCity","UPSantaTeresa",...
    "UPSparks","UPTucson"]';

intervalcol=strings(length(IntermodalLabels),1);
nodetypescol=strings(length(IntermodalLabels),1);
latitudesIT=Latitude_Longitude(:,1);
longitudesIT=Latitude_Longitude(:,2);


for i=1:length(nodetypescol)
   nodetypescol(i)="Warehouse"; 
end


row16=ones(length(IntermodalLabels),1)*16;
Itable = table(row16,IntermodalLabels,...
    intervalcol,latitudesIT,longitudesIT,...
    nodetypescol,...
    'VariableNames',...
    {'ID' 'Label' 'Interval' 'Latitude' 'Longitude' 'Node-Type'});

% Now all the tables are made. Itable represents the table of new 
% warehouse locations. WH is the table of ports, warehouses, and stores. 
%% Preparing the network graph
% Here are some distance vectors for the distances between the ports 
% of LA and Long Beach to each store. 
ShortestPathDistanceVectorsLA=zeros(length(nodetypescol),17);
ShortestPathMapVectorsLA=zeros(17,30);
ShortestPathDistanceVectorsLongBeach=zeros(length(nodetypescol),17);
ShortestPathMapVectorsLongBeach=zeros(17,30);
% Plotting commands so that all the plots go on one figure. The
% plots for LA and Long Beach will be identical because they were set up
% as a dummy source. 

% One rationale for this is that the worst case scenario is where drayage
% must be used all the way, which means that the distance from the
% warehouses in terms of drayage becomes the primary concern in terms of
% cost. The path to the warehouse can be optimized every time and is a sunk
% cost, so it is ignored. 

LA=figure();
set(0,'CurrentFigure',LA)
tiledlayout('flow')
LongBeach=figure();
set(0,'CurrentFigure',LongBeach)
tiledlayout('flow')
%  In a loop, building csv node and edge tables for gephi and then 
%  making a directed graph. 
for facilitynumber=1:length(latitudesIT)
%node table
fname = sprintf('NODEtable%d.csv', facilitynumber);
comp = [WH;Itable(facilitynumber,:)];
writetable(comp,fname);

%edge table
dist=sqrt((table2array(WH(2:end,4))-table2array(Itable(facilitynumber,4))).^2 +...
    (table2array(WH(2:end,5))-table2array(Itable(facilitynumber,5))).^2);
inversedist=1./dist;
% Inverse distance can be useful in gephi because by default it inverts
% closeness based on distances
secondwarehousetable=...
    [ESE404IKEAOperationsEdgestry1bottomleft ...
    array2table(inversedist)...
    array2table(dist)];
allVars = 1:width(secondwarehousetable);
secondwarehousetable=renamevars(secondwarehousetable,allVars,...
    {'Source' 'Target' 'Type' 'ID' 'Label' 'Weight' 'WeightReg'});
% ESE404IKEAOperationsEdgestry1=renamevars(ESE404IKEAOperationsEdgestry1,...
%     allVars,{'Source' 'Target' 'Type' 'ID' 'Label' 'Weight' 'WeightReg'});
compedges=[ESE404IKEAOperationsEdgestry1(2:end,:);secondwarehousetable];
fname = sprintf('EDGEtable%d.csv', facilitynumber);
writetable(compedges,fname)
%Matlab digraph
% This graph is made once for every location we needed to test
s=table2array(compedges(:,1))'+1; % source nodes in the directed graph
t=table2array(compedges(:,2))'+1;  % target nodes
weights=table2array(compedges(:,7))'; %weights on the edges
weights(1)=0;        %dummy source, cost LA-> current dist. center =0
weights(2)=0;        %dummy source, cost LB-> current dist. center =0
weights(16)=0;       %dummy source, cost LA-> trial dist. center   =0
weights(17)=0;       %dummy source, cost LB-> trial dist. center   =0
nodenames=table2array(comp(:,2))';
% Making the graph to represent the current network with the given 
% new distribution center
G=digraph(s,t,weights,nodenames); %<---- the complete graph 

set(0,'CurrentFigure',LA) %choose plotting window
nexttile %create new plotting figure
[TR,D] = shortestpathtree(G,2,'Method','positive'); %<-----subgraph 
% representing the shortest path from node 2 (Port of LA) to all terminal
% destinations, which are stores. The chosen path will be the shortest path
% according to Dijkstra's algorithm, which is bounded below and above by 

%                       (Nodes+Edges)*log(Edges)



p = plot(TR);
TR.Nodes.NodeColors = outdegree(TR);
p.NodeCData = TR.Nodes.NodeColors;
highlight(p,TR,'EdgeColor','r')
ShortestPathDistanceVectorsLA(facilitynumber,:) = D;
% ShortestPathMapVectorsLA(facilitynumber,:)=E;

%Long beach to stores
set(0,'CurrentFigure',LongBeach)
nexttile
[TR,D,E] = shortestpathtree(G,3,'Method','positive');
p = plot(TR);
TR.Nodes.NodeColors = outdegree(TR);
p.NodeCData = TR.Nodes.NodeColors;
highlight(p,TR,'EdgeColor','g')
ShortestPathDistanceVectorsLongBeach(facilitynumber,:) = D;
% ShortestPathMapVectorsLongBeach(facilitynumber,:)=E;
end

%% Finding total shortest paths for each port for each warehouse

%First have to remove inf values
SPLBinf=isinf(ShortestPathDistanceVectorsLongBeach);
LB=ShortestPathDistanceVectorsLongBeach;
LB(SPLBinf)=0;
LB=sum(LB,2);

SPLAinf=isinf(ShortestPathDistanceVectorsLA);
LA=ShortestPathDistanceVectorsLA;
LA(SPLAinf)=0;
LA=sum(LA,2);

TotalPaths=LA+LB;

[minvalue,index]=min(TotalPaths)
disp('BEST OPTION')
disp('---------------------------------------------')
IntermodalLabels(index)

facilitynumber=index;
comp = [WH;Itable(facilitynumber,:)];
dist=sqrt((table2array(WH(2:end,4))-table2array(Itable(facilitynumber,4))).^2 +...
(table2array(WH(2:end,5))-table2array(Itable(facilitynumber,5))).^2);
inversedist=1./dist;
secondwarehousetable=...
[ESE404IKEAOperationsEdgestry1bottomleft ...
array2table(inversedist)...
array2table(dist)];
allVars = 1:width(secondwarehousetable);
secondwarehousetable=renamevars(secondwarehousetable,allVars,...
{'Source' 'Target' 'Type' 'ID' 'Label' 'Weight' 'WeightReg'});
compedges=[ESE404IKEAOperationsEdgestry1;secondwarehousetable];
s=table2array(compedges(:,1))'+1;
t=table2array(compedges(:,2))'+1;
weights=table2array(compedges(:,7))';
weights(1)=0;
weights(2)=0;
weights(16)=0;
weights(17)=0;
nodenames=table2array(comp(:,2))';
G=digraph(s(2:end),t(2:end),weights(2:end),nodenames);
[TR,D,E] = shortestpathtree(G,2,'Method','positive');
figure()
p = plot(TR);
TR.Nodes.NodeColors = outdegree(TR);
p.NodeCData = TR.Nodes.NodeColors;
highlight(p,TR,'EdgeColor','r')
T=sort(TotalPaths(:));
T(2)
disp('2nd BEST OPTION')
disp('---------------------------------------------')



IntermodalLabels(TotalPaths==T(2))
T(3)
disp('3rd BEST OPTION')
disp('---------------------------------------------')
IntermodalLabels(TotalPaths==T(3))
disp('4th BEST OPTION')
disp('---------------------------------------------')
IntermodalLabels(TotalPaths==T(4))
