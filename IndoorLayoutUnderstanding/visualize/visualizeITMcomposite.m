function visualizeITMcomposite(x, isolated, comp)

pg = parsegraph();
pg.childs = comp.chindices;
pg = findConsistent3DObjects(pg, x);
show2DGraph(pg, x, icluster);

end