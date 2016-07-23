% The demo for Cluster-based Co-saliency Detection in multiple images

clc;clear all;
tic;
addpath('./others/');
result=strcat('.\result_pair\');
file_path='.\images_pair\';
gt_path='.\saliencymap\pair\';
files=dir([file_path '*.bmp']);


length=size(files,1);
ScaleH=150; 
ScaleW=150;
Bin_num=10;
Img_num=2;
tic;
for o=1:2:(length-1)
    disp(o);
    flag=(o-1)/2;
    daxiao=zeros(2,Img_num);
    All_vector=[];
    All_img=[];
    for i=o:o+1
       path=strcat(file_path, files(i,1).name);
       [p,q,t]=size(imread(path));
       daxiao(1,i-flag*2)=p;
       daxiao(2,i-flag*2)=q;
       [imvector img DisVector]=GetImVector(path, ScaleH, ScaleW,0);
        All_vector=[All_vector; imvector];
        All_img=[All_img img];
    end

    [idx, ctrs, bCon, sumD, D] = litekmeans(All_vector, Bin_num,'MaxIter',5,'Replicates',1);
    
    opts.ancs=ctrs;
    opts.mode='given';
    opts.p=Bin_num;
    opts.r=4;
    opts.a=0.5;
    model=EMR(All_vector,opts);
    
    score4=zeros(ScaleH*ScaleW*Img_num,Img_num);
    score_norm=zeros(ScaleH*ScaleW*Img_num,Img_num);
    %%
    Yt1=zeros(ScaleH*ScaleW*Img_num,1);
    for ii=o:o+1
       path=strcat(gt_path, strrep(files(ii,1).name,'.bmp','_ICASSP.png'));
       f=im2single(imread(path));
       f=imresize(f,[ScaleH ScaleW]);
       for j=1:ScaleH
           for i=1:ScaleW
               if f(j, i)>=0
                    Yt1(j +(i-1)*ScaleH+ScaleH*ScaleW*(mod(ii-1,Img_num)))=f(j, i);
               end
           end
       end
    end
    score_ini = Yt1- model.H*(model.C*(model.H'* Yt1)); 
    
    for ii=1:Img_num
        Yt=zeros(ScaleH*ScaleW*Img_num,1);
        Yt(ScaleH*ScaleW*(ii-1)+1:ScaleH*ScaleW*ii)=score_ini(ScaleH*ScaleW*(ii-1)+1:ScaleH*ScaleW*ii);
        score4(:,ii) = Yt- model.H*(model.C*(model.H'* Yt)); 
    end
    
    Sal_co=zeros(Bin_num,Img_num);
    for i=1:Img_num
        index_vec = idx((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW);
        index_sal = Yt1((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW);
        Sal_sum=zeros(Bin_num,1);
        Sal_count=ones(Bin_num,1);
        for j=1:ScaleH*ScaleW
            Sal_sum(index_vec(j))=Sal_sum(index_vec(j))+index_sal(j);
            Sal_count(index_vec(j))=Sal_count(index_vec(j))+1;
        end
        Sal_co(:,i)=Sal_sum(:)./Sal_count(:);
    end
    Sal_distribute=sum(Sal_co,2)./Img_num;
    th=mean(Sal_distribute);
    Sal_distribute=Sal_distribute>=th;

    for j=1:Img_num
        for i=1:Img_num
            vec=score4((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW,j);
            score_norm((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW,j)=vec;
        end
    end

    bool=zeros(ScaleH*ScaleW*Img_num,Img_num);
    for j=1:Img_num
        for i=1:Img_num
            vec=score_norm((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW,j);
            th=mean(vec);
            bool((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW,j)=vec>=th;
        end
    end
       boo=sum(bool,2);
   boo=boo>fix(Img_num/2);
   
    score_s=zeros(ScaleH*ScaleW*Img_num,1); 
    for i=1:Img_num
        score_s=score_s+score_norm(:,i);
    end
    score_s=score_s./Img_num;
   
    score_m=ones(ScaleH*ScaleW*Img_num,1); 
    for j=1:Img_num
        score_m=score_m.*score_norm(:,j);
    end

    score=zeros(ScaleH*ScaleW*Img_num,1); 
    for i=1:ScaleH*ScaleW*Img_num
        if boo(i)==1 
             score(i)=score_s(i);
        else
             score(i)=score_m(i);
        end
    end
    
    score1=MeanSh(All_img,score,Img_num,ScaleH, ScaleW);
    for i=1:Img_num
       vec=score1((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW);
       vec=Nor(vec);
       SM1=reshape(vec,[ScaleH ScaleW]);
       SM1=imresize(SM1,[daxiao(1,i) daxiao(2,i)]);
       imwrite(SM1,strcat(result, strrep(files(i+flag*2,1).name,'.bmp','_co.png')));   
    end
end
toc;







