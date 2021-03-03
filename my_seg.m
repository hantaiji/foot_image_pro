function []=my_seg(seg_i)
%
seg_code_a=strcat('./footIR_',num2str(seg_i), '.jpg');
img=imread(seg_code_a);
% figure(1);
% subplot(2,3,1);%在平铺位置创建坐标区。2行3列第一张
% imshow(img);%展示原图
C = makecform('srgb2lab');       %设置转换格式
img_lab = applycform(img, C);
ab = double(img_lab(:,:,2:3));    %取出lab空间的a分量和b分量
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
 
nColors = 3;        %分割的区域个数为3
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);  %重复聚类3次
pixel_labels = reshape(cluster_idx,nrows,ncols);
% subplot(2,3,2);
% imshow(pixel_labels,[]), title('聚类结果');%展示聚类结果
 
 
%显示分割后的各个区域、整体灰度图
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
 
for k = 1:nColors
    color = img;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end          
% subplot(2,3,3);
% imshow(segmented_images{1}), title('分割结果——区域1');
% subplot(2,3,4);
% imshow(segmented_images{2}), title('分割结果——区域2');
% subplot(2,3,5);
% imshow(segmented_images{3}), title('分割结果——区域3');
% subplot(2,3,6);
% imshow(rgb2gray(img));
%%
%从分类结果中确定足底图像
I_1=rgb2gray(segmented_images{1});
I_2=rgb2gray(segmented_images{2});
I_3=rgb2gray(segmented_images{3});
% figure(2);  
% subplot(1,3,1);
% imshow(I_1);
% subplot(1,3,2);
% imshow(I_2);
% subplot(1,3,3);
% imshow(I_3);

if sum(sum(I_1))<sum(sum(I_2))&&sum(sum(I_1))<sum(sum(I_3))
    I=I_1;
else
    if sum(sum(I_2))<sum(sum(I_3))
        I=I_2;
    else
        I=I_3;
    end
end 
%%
%显示分割后图像（转换成灰度图）的灰度直方图
% hold on;
% figure(3);
% subplot(3,1,1);
% z=rgb2gray(segmented_images{1});
% imhist(z);
% subplot(3,1,2);
% z=rgb2gray(segmented_images{2});
% imhist(z);
% subplot(3,1,3);
% z=rgb2gray(segmented_images{3});
% imhist(z);
%%
%将足底图像分成左右足两张子图，以用于后续分别进行垂直对齐
[M, N, C] = size(I); %获取图像的大小
m = M; %每张小图的长
n = N/2;%每张小图的宽
count = 1; %计数
%rebulid = zeros(M, N, C); %生成与原图大小的全黑图,用于图像重建
%figure(3);
for i = 1:M/m
    for j = 1:N/n
        block = I((i-1)*m+1 : i*m, (j-1)*n+1 : j*n, :); %生成小图
        imwrite(block, strcat('footIR_',num2str(seg_i),'第',num2str(count), '幅图','.png')); %保存每张小图
        %subplot(2,2,count),imshow(block),title(['footIR_',num2str(seg_i),'第',num2str(count),'幅图']); %将小图显示在一张图中
        count = count + 1; %计数加一
%        rebuild((i-1)*m+1:i*m, (j-1)*n+1:j*n, :) = block; %重建原图
    end
end

%figure(4);imshow(rebuild); title('重建原图')%显示原图

%%
%确定足底图像中心点
% figure(4);
% subplot(1,3,1);
% imshow(I);
% Ibw = imbinarize(I,0.1);%转二值图像(要设置level)
% subplot(1,3,2);
% imshow(Ibw);
% %Ilabel = bwlabel(Ibw);
% stat = regionprops(Ibw,'centroid');
% %subplot(1,3,2);
% %imshow(Ilabel);
% hold on;
% for x = 1: numel(stat)
%     plot(stat(x).Centroid(1),stat(x).Centroid(2),'ro');
% end
%%
end