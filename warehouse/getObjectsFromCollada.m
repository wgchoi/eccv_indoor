function Objects = getObjectsFromCollada(filename)

global Geometries LibNodes;

Collada = xml2struct(filename);

Scene = findNodeByName(Collada, 'scene');

LibNodes = findNodeByName(Collada, 'library_nodes');
Geometries = findNodeByName(Collada, 'library_geometries');

TempNode = findNodeByName(Scene, 'instance_visual_scene');

SearchString = findAttributeValue(TempNode, 'url');

TempNode = findNodeByName(Collada, 'library_visual_scenes');

i = 1;
while (~strcmpi(TempNode.children(i).name, 'visual_scene') && ~strcmpi(TempNode.children(i).id, SearchString))
    i = i + 1;
end
Scene = TempNode.children(i);

ModelFound = 0;
for i = length(Scene.children)-1:-2:2
    if strcmpi(Scene.children(i).name, 'node')
        TempNode = findNodeByName(Scene.children(i), 'instance_camera');
        if isempty(TempNode)
            ModelFound = 1;
            break
        end
    end
end
if ModelFound == 1
    Model = Scene.children(i);
else
    error('no 3D model in the scene');
end
% while length(Model.children) == 3
%     Model = Model.children(1);
% end

Objects = getInstanceGeometry(Model);

% for i = 2:2:length(Model.children)-1
%     Objects(round(i/2)).struct = getInstanceGeometry(Model.children(i));
%     Objects(round(i/2)).name = Model.children(i).id;
%     [Objects(round(i/2)).positions Objects(round(i/2)).triangles] = getPositionsFromChildren(Objects(round(i/2)));
%     Objects(round(i/2)).matrix = eye(4);
% %     Objects(round(i/2)) = findStructureTransform(Objects(round(i/2)));
% end
clear Geometries LibNodes;
        
                

function out = xml2struct(xmlfile) 
% XML2STRUCT Read an XML file into a MATLAB structure.

xml = xmlread(xmlfile); 

children = xml.getChildNodes; 
for i = 1:children.getLength
    out(i) = node2struct(children.item(i-1)); 
end

function s = node2struct(node)

s.name = char(node.getNodeName); 
s.id = [];
if node.hasAttributes
    attributes = node.getAttributes;
    nattr = attributes.getLength;
    s.attributes = struct('name',cell(1,nattr),'value',cell(1,nattr));

    for i = 1:nattr
        attr = attributes.item(i-1);
        s.attributes(i).name = char(attr.getName);
        s.attributes(i).value = char(attr.getValue);
        if strcmpi(char(attr.getName), 'id')
            s.id = char(attr.getValue);
        end
    end
else
    s.attributes = [];
end

try
    s.data = char(node.getData);
catch
    s.data = '';
end

if node.hasChildNodes
    children = node.getChildNodes;
    nchildren = children.getLength;
    c = cell(1,nchildren);
    s.children = struct('name',c, 'id', c, 'attributes',c,'data',c,'children',c);

    for i = 1:nchildren
        child = children.item(i-1);
        s.children(i) = node2struct(child);
    end
else
    s.children = [];
end 

function OutNode = findNodeByName(InNode, Name)

i = 1;
while ~strcmpi(InNode.children(i).name, Name)
    i = i + 1;
    if i > length(InNode.children)
        break;
    end
end
if i > length(InNode.children)
    OutNode = [];
else
    OutNode = InNode.children(i);
end

function value = findAttributeValue(node, str)

i = 1;
nAttr = length(node.attributes);

while ~strcmpi(node.attributes(i).name, str) || i > nAttr
    i = i + 1;
end
if i <= nAttr
    value = node.attributes(i).value(2:end);
else
    error(['No such attribute as', str]);
end

function OutNode = findNodeById(InNode, str)

i = 1;
while ~strcmpi(InNode.children(i).id, str)
    i = i + 1;
    if i > length(InNode.children)
        break;
    end
end
if i > length(InNode.children)
    OutNode = [];
else
    OutNode = InNode.children(i);
end

function structure = getInstanceGeometry(InNode)

global LibNodes Geometries;
structure = struct('name', {}, 'positions', {}, 'triangles', {}, 'struct', {}, 'matrix', {});
NumStructs = 0;

for i = 2:2:length(InNode.children)-1
    if strcmpi(InNode.children(i).name, 'instance_node')
        
        SearchString = findAttributeValue(InNode.children(i), 'url');
        TempNode = findNodeById(LibNodes, SearchString);
        NumStructs = NumStructs + 1;
        structure(NumStructs).struct = getInstanceGeometry(TempNode);
        if ~isempty(InNode.children(i).id)
            structure(NumStructs).name = InNode.children(i).id;
        else
            structure(NumStructs).name = strcat('part', num2str(NumStructs));
        end
        [structure(NumStructs).positions structure(NumStructs).triangles] = getPositionsFromChildren(structure(NumStructs));
        
        structure(NumStructs).matrix = eye(4);
        MatNode = findNodeByName(InNode, 'matrix');
        if ~isempty(MatNode)
            Matrix = str2num(MatNode.children.data);
            if size(Matrix, 1) == 1
                Matrix = reshape(Matrix, [4 4])';
            end
            structure(NumStructs).positions = Matrix*structure(NumStructs).positions;
            structure(NumStructs).matrix = Matrix;
        end
        
    elseif strcmpi(InNode.children(i).name, 'instance_geometry')
        
        SearchString = findAttributeValue(InNode.children(i), 'url');
        InstNode = findNodeById(Geometries, SearchString);
        NumStructs = NumStructs + 1;
        structure(NumStructs).struct = [];
        if ~isempty(InNode.children(i).id)
            structure(NumStructs).name = InNode.children(i).id;
        else
            structure(NumStructs).name = strcat('part', num2str(NumStructs));
        end
        [structure(NumStructs).positions structure(NumStructs).triangles] = getPositions(InstNode);
        
        structure(NumStructs).matrix = eye(4);
        MatNode = findNodeByName(InNode, 'matrix');
        if ~isempty(MatNode)
            Matrix = str2num(MatNode.children.data);
            if size(Matrix, 1) == 1
                Matrix = reshape(Matrix, [4 4])';
            end
            structure(NumStructs).positions = Matrix*structure(NumStructs).positions;
            structure(NumStructs).matrix = Matrix;
        end
        
    elseif strcmpi(InNode.children(i).name, 'node')
        
        NumStructs = NumStructs + 1;
        structure(NumStructs).struct = getInstanceGeometry(InNode.children(i));
        if ~isempty(InNode.children(i).id)
            structure(NumStructs).name = InNode.children(i).id;
        else
            structure(NumStructs).name = strcat('part', num2str(NumStructs));
        end
        [structure(NumStructs).positions structure(NumStructs).triangles] = getPositionsFromChildren(structure(NumStructs));
        
        structure(NumStructs).matrix = eye(4);
        MatNode = findNodeByName(InNode, 'matrix');
        if ~isempty(MatNode)
            Matrix = str2num(MatNode.children.data);
            if size(Matrix, 1) == 1
                Matrix = reshape(Matrix, [4 4])';
            end
            structure(NumStructs).positions = Matrix*structure(NumStructs).positions;
            structure(NumStructs).matrix = Matrix;
        end
        
    end
end

function [Positions Triangles] = getPositions(Node)

Triangles = [];
Mesh = findNodeByName(Node, 'mesh');
Input = findNodeByName(findNodeByName(Mesh, 'vertices'), 'input');
SearchString = findAttributeValue(Input, 'source');
Source = findNodeById(Mesh, SearchString);
ArrayNode = findNodeByName(Source, 'float_array');
Vector = str2num(ArrayNode.children.data);
Positions = ones(4, length(Vector)/3);
Positions(1:3, :) = reshape(Vector, 3, length(Vector)/3);
% Offset = size(Positions, 2) + 1;
% Positions = [Positions Array];
for i = 2:2:length(Mesh.children)
    if strcmpi(Mesh.children(i).name, 'triangles')
        stride = 0;
        for j = 2:2:length(Mesh.children(i).children)
            if strcmpi(Mesh.children(i).children(j).name, 'input')
                stride = stride + 1;
            end
        end
        Assign = findNodeByName(Mesh.children(i), 'p');
        AssignVect = str2num(Assign.children.data);
        TriVect = AssignVect(1:stride:end) + 1;
        TriArray = reshape(TriVect, 3, length(TriVect)/3); 
%         TriArray = TriArray + Offset;
        Triangles = [Triangles TriArray];   % Otherwise it reads only the last triangle
    end
end

function [Positions Triangles] = getPositionsFromChildren(InStruct)

Positions = [];
Triangles = [];

for i = 1:length(InStruct.struct)
    Offset = size(Positions, 2);
    Positions = [Positions InStruct.struct(i).positions];
    tri = Offset + InStruct.struct(i).triangles;
    Triangles = [Triangles tri];
end

% function OutStruct = findStructureTransform(InStruct)
% Positions = [];
% for i = 1:length(InStruct.struct)
%     OutStruct = InStruct;
%     OutStruct.struct(i).matrix = OutStruct.matrix*OutStruct.struct(i).matrix;
%     if isempty(OutStruct.struct(i).struct) %don't stop until instance geometry node
%         OutStruct.struct(i) = findStructureTransform(OutStruct.struct(i));
%     else
%         OutStruct.struct(i).positions = OutStruct.struct(i).matrix*OutStruct.struct(i).positions;
%     end
%     Positions = [Positions OutStruct.struct(i).positions];
% end
% OutStruct.positions = Positions;