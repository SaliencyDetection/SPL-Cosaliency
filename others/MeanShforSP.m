function Refinement_Saliency=MeanShforSP(path,SM1)

     Or=im2double(imread(path));
     [h,w,s]=size(Or);
     [HER segments2] = edison_wrapper(Or,@RGB2Luv,'RangeBandWidth',6.5,'MinimumRegionArea',240);
     segments2 = 1+segments2;
     labelnumber=max(segments2(:));
     seg_mean2=zeros(labelnumber,1);%显著性均值
     seg_count2=zeros(labelnumber,1);%面积2
     
     regions = calculateRegionProps(labelnumber,segments2);
     sup_feat = extractSupfeat(SM1,regions,labelnumber);
     
     Refinement_Saliency=zeros(h,w);
     for i=1:1:h
        for j=1:1:w 
            Refinement_Saliency(i,j)=sup_feat(segments2(i,j));
        end
     end
    Refinement_Saliency=(Refinement_Saliency-min(Refinement_Saliency(:)))/(max(Refinement_Saliency(:))-min(Refinement_Saliency(:)));
end



