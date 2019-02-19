function [final_locs, final_pks] = remove_OverlappingPeaks(locs, pks, MinSacIntDuration)

id = find( abs( diff(locs)-1) <= MinSacIntDuration);
temp = [pks(id)';pks(id+1)'];
[~,removalinds] = nanmin( abs(temp),[],1 );
removalinds = id'+(removalinds-1);
removalinds = unique( removalinds );
locs(removalinds) = [];
pks(removalinds) = [];

final_locs = locs; final_pks = pks;