function showOneExample(img, gtPolyg, objs, imgout)

vp = getVPfromGT(img, gtPolyg);
vp = order_vp(vp); % v, h, m

ShowGTPolyg(img, gtPolyg, 10);
[K, R, F] = get3Dcube(img, vp, gtPolyg);

objmodel = objmodels();
drawCube(F, gtPolyg, K, R, objs, objmodel, 1.4);

if (nargin == 4)
    drawnow;
    figure(10);
    print('-djpeg', [imgout '_2D.jpg']);
    figure(20);
    print('-djpeg', [imgout '_3D.jpg']);
    figure(30);
    print('-djpeg', [imgout '_VP.jpg']);
end

end