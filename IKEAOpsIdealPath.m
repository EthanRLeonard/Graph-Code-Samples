%% Instantiating the distances
%UP to stores 
UPDIST = readmatrix('UPDistances.csv');
Stores=["Tempe Store (AZ)","Draper Store (UT)",...
"Centennial Store (CO)","Vegas Store (NV)",...
"San Diego Store (CA)","Carson Store (CA)"...
"Covina Store (CA)","Palo Alto Store (CA)"...
"Emeryville Store (CA)","Sacramento Store (CA)"...
"Costa Mesa Store (CA)","Burbank Store (CA)"...
"Albuquerque Store(NM)"]';
%BNSF to stores
BNSFDIST = readmatrix('BNSFDistances.csv');
%BNSF to other BNSF terminals
BNSFLINES = readtable('LINESBNSF.csv');
BNSFLINES = BNSFLINES(2:end,[1 3]);
%UP to other UP terminals
UPLINES = readtable('LINESUP.csv');
UPLINES = UPLINES(:,[1 3]);

IntermodalLabels = ["BNSFAlbuquerque","BNSFDenver","BNSFLosAngeles",...
    "BNSFOakLand","BNSFPhoenix","BNSFSanBernardino","BNSFStockton",...
    "UPBarstow","UPDenver","UPInlandEmpire","UPLasVegas","UPLathrop",...
    "UPLosAngeles","UPOakland","UPSaltLakeCity","UPSantaTeresa",...
    "UPSparks","UPTucson"]';

Labels = [IntermodalLabels;Stores];
warehouses= ["Lebec" ; "Albuquerque";"Port"];
Labels= [Labels ; warehouses];
LINES = [renamevars(BNSFLINES,[1 2], {'lines' , 'relative distance'})...
    ; renamevars(UPLINES,[1 2],{'lines', 'relative distance'})];

id = linspace(1,34,34)'; idlabel = [id, Labels];


%% Reading in the data 
InterMDists = readmatrix('InterMDists.csv'); %distances between IM 
% (InterModal) facilities
sdists = readmatrix('sdists.csv');  %distances between stores and IM 
WHtoI = readmatrix('WHtoIM.csv');   %distances between warehouses and IM
%% Nodes for the graph
s = [InterMDists(:,1) ; sdists(:,1); WHtoI(:,1)]; %start nodes
s = [s ; 34 ; 34]; %dummy source goes to both warehouses (start coordinate)
s = [s;wh2stores_stw(:,1)];
t = [InterMDists(:,2) ; sdists(:,2); WHtoI(:,2)]; %end nodes
t = [t ; 32 ; 33]; %both warehouses receiving from the dummy source (end)
t = [t;wh2stores_stw(:,2)];
weights = [InterMDists(:,3); sdists(:,3); WHtoI(:,3)]; 
weights = [weights;0;0]; %zero weight for dummy source 
weights = [weights;wh2stores_stw(:,3)];
G = digraph(s,t,weights,Labels);  figure() %making the complete graph
[TR,D,E] = shortestpathtree(G,34,'Method','positive'); %<--port node to all
% other nodes
p = plot(TR);





TR.Nodes.NodeColors = outdegree(TR);
p.NodeCData = TR.Nodes.NodeColors;
highlight(p,TR,'EdgeColor','r')



