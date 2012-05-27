Folder indoordataset.zip has the data we used for our work pubslished in ICCV 2009, ECCV 2010 and CVPR 2012.

Each label file in GTSpatiallayout has 

'fields'- Segmentation mask for 1-floor 2-middle wall 3-right wall 4-left wall 5-ceiling. This mask also contains occluded boundaries between walls and floor etc and is marked as if the room was empty. 

'gtPolyg'- Polygons for different faces of room box  1-floor 2-middle wall 3-right wall 4-left wall 5-ceiling. 

'labels'-Segmentation mask for 1-floor 2-middle wall 3-right wall 4-left wall 5-ceiling 6-object. This includes only visible support region for different walls, floor ceiling and objects. Different objects are marked as single 'object' category. 


Each file in GT3dcuboids has

'annotation' - Cuboid mark up for different objects such as sofa, chair table etc in the scene. Baseblock and headrest are marked separately. Information on whether the object is occulded, cropped is also included.

