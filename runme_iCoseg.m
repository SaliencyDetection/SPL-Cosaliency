% The demo for Cluster-based Co-saliency Detection in multiple images

clc;clear all;
tic;
addpath('.\others\');
rootresult=strcat('./result_iCoseg/');
namepath= '.\images_iCoseg\';
foldername=dir(namepath);
[m n]=size(foldername);
p=3;
tic;
for qqq=p:m
disp(qqq);
file_path=strcat(namepath,foldername(qqq,1).name, '/');
files=dir([file_path '*.jpg']);

result=strcat(rootresult,foldername(qqq,1).name);
mkdir(result);

Img_num=size(files,1);
ScaleH=128; 
ScaleW=128; % Scale 

%clustering number on multi-image
Bin_num=min(max(2*Img_num,10),30);
Bin_num=50;
%% ------ Obtain the co-saliency for multiple images-------------
%----- obtaining the features -----
daxiao=zeros(2,Img_num);

for i=1:Img_num
   disp(i)
   path=strcat(file_path, files(i,1).name);
   [p,q,t]=size(imread(path));
   daxiao(1,i)=p;
   daxiao(2,i)=q;
   [imvector img DisVector]=GetImVector(path, ScaleH, ScaleW,0);
    if i==1
        All_vector=imvector;
        All_img=img;
    else 
        All_vector=[All_vector; imvector];
        All_img=[All_img img];
    end
end

[idx, ctrs, bCon, sumD, D] = litekmeans(All_vector, Bin_num,'MaxIter',5,'Replicates',1);

opts.ancs=ctrs;
opts.mode='given';
opts.p=Bin_num;
opts.r=4;
opts.a=0.5;
model=EMR(All_vector,opts);

gt_path='.\saliencymap\iCoseg\';
score4=zeros(ScaleH*ScaleW*Img_num,Img_num);
score_ini=zeros(ScaleH*ScaleW*Img_num,1);
score_norm=zeros(ScaleH*ScaleW*Img_num,Img_num);
%%  
Yt1=zeros(ScaleH*ScaleW*Img_num,1);  

for ii=1:Img_num
   path=strcat(gt_path, strrep(files(ii,1).name,'.jpg','_ICASSP.png'));
   f=im2single(imread(path));
   f=imresize(f,[ScaleH ScaleW]); 
   th=mean(f(:));
   f=f>=(th);
       for j=1:ScaleH
           for i=1:ScaleW
               if f(j, i)>=0
                    Yt1(j +(i-1)*ScaleH+ScaleH*ScaleW*(mod(ii-1,Img_num)))=f(j, i);
               end
           end
       end
end

score_ini = Yt1- model.H*(model.C*(model.H'* Yt1)); 


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

for ii=1:Img_num
   Yt=zeros(ScaleH*ScaleW*Img_num,1);      
   Yt((ii-1)*ScaleH*ScaleW+1:ii*ScaleH*ScaleW)=score_ini((ii-1)*ScaleH*ScaleW+1:ii*ScaleH*ScaleW);
        score4(:,ii) = Yt- model.H*(model.C*(model.H'* Yt));  
end

%% first
   score=Co_saliency(score4,Img_num,ScaleH,ScaleW,Sal_distribute,idx);
%%
     for i=1:Img_num
        path=strcat(file_path, files(i,1).name);
        vec=score((i-1)*ScaleH*ScaleW+1:i*ScaleH*ScaleW);
        vec=Nor(vec);
        SM=reshape(vec,[ScaleH ScaleW]);
        SM=imresize(SM,[daxiao(1,i) daxiao(2,i)]);
        SM=MeanShforSP(path,SM);
        imwrite(SM,strcat(result,'\', strrep(files(i,1).name,'.jpg','_co.png')));  
     end
clear model;
end
toc;



