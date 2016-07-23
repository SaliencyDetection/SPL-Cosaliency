function score1=MeanSh(All_img,score,Img_num, ScaleH, ScaleW)
score1=zeros(ScaleH*ScaleW*Img_num,1);
 for ii=1:Img_num
     Or=All_img(:,(ii-1)*ScaleH+1:ii*ScaleH,:);
%      Or=reshape(Or,[ScaleH ScaleW 3]);
     vec=score((ii-1)*ScaleH*ScaleW+1:ii*ScaleH*ScaleW);
     vec=Nor(vec);
     vec=reshape(vec,[ScaleH ScaleW]);
     [HER segments2] = edison_wrapper(Or,@RGB2Luv,'RangeBandWidth',6.5,'MinimumRegionArea',80);
     segments2 = 1+segments2;
     labelnumber=max(segments2(:));
     seg_mean2=zeros(labelnumber,1);%显著性均值
     seg_count2=zeros(labelnumber,1);%面积2
     
     regions = calculateRegionProps(labelnumber,segments2);
     sup_feat = extractSupfeat(vec,regions,labelnumber);
     
%      vec=All_vector((ii-1)*ScaleH*ScaleW+1:ii*ScaleH*ScaleW);
%      vec=Nor(vec);
%      vec=reshape(vec,[ScaleH ScaleW]);
%      seg_vec = extractSupfeat(vec,regions,labelnumber);
%      
%      sup_feat = smooth(sup_feat,labelnumber,seg_vec);

%      for i=1:1:ScaleH
%         for j=1:1:ScaleW 
%             seg_mean2(segments2(i,j),:)=seg_mean2(segments2(i,j),:)+vec(i,j);
%             seg_count2(segments2(i,j))=seg_count2(segments2(i,j))+1;
%         end
%      end
%      seg_mean2=seg_mean2./seg_count2;
     Refinement_Saliency=zeros(ScaleH,ScaleW);
     for i=1:1:ScaleH
        for j=1:1:ScaleW 
            Refinement_Saliency(i,j)=sup_feat(segments2(i,j));
        end
     end
    Refinement_Saliency=(Refinement_Saliency-min(Refinement_Saliency(:)))/(max(Refinement_Saliency(:))-min(Refinement_Saliency(:)));
    Refinement_Saliency=reshape(Refinement_Saliency,[ScaleH*ScaleW 1]);
    score1((ii-1)*ScaleH*ScaleW+1:ii*ScaleH*ScaleW)=Refinement_Saliency;
    vec=[];
end



