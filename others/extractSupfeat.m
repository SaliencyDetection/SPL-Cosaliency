function sup_feat= extractSupfeat(vec,regions,sup_num)
   
sup_feat = [];
for r = 1:sup_num
	ind = regions{r}.pixelInd;
	sup_feat = [sup_feat;mean(vec(ind))];
end

