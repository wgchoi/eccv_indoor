Copyright (C) 2010 Varsha Hedau, University of Illinois at Urbana Champaign.

To use this dataset you must cite 
Varsha Hedau, Derek Hoiem, David Forsyth, “Thinking Inside the Box: 
Using Appearance Models and Context Based on Room Geometry,” ECCV 2010.


This Folder has the data we used for our work pubslished in ECCV 2010.
Each label file has 
'fields'- Segmentation mask for 1-floor 2-middle wall 3-right wall 4-left wall 5-ceiling. This mask also contains occluded boundaries between walls and floor etc and is marked as if the room was empty. 

'gtPolyg'- Polygons for different faces of room box  1-floor 2-middle wall 3-right wall 4-left wall 5-ceiling. 

'labels'-Segmentation mask for 1-floor 2-middle wall 3-right wall 4-left wall 5-ceiling 6-object. This includes only visible support region for different walls, floor ceiling and objects. Different objects are marked as single 'object' category. 

Each box.mat file has 

'annotation' -bed markup that consist of 8 corners of bed's baseblock and backrest and orientation of the bed as 1 to 4 depending on which of the 4 walls of the box layout the bed is facing. It also consists of cropped, occlusion and difficult flags which are 1 when true.

    


 
