function params = filterITMpatterns(params, hit, mincount)

retain = hit >= mincount;
itmptns = params.model.itmptns(retain);

params = appendITMtoParams(params, itmptns);

end