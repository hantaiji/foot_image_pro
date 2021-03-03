function [uint_analyzed_img,average,min,max]=my_analysis(analysis_i)%此处后续需要更改
analysis_r=strcat('./footIR_',num2str(analysis_i),'旋转后的第1幅图','.png');
analysis_l=strcat('./footIR_',num2str(analysis_i),'旋转后的第2幅图','.png');
right_analy_img=double(imread(analysis_r));
left_analy_img=double(imread(analysis_l));
left_analy_img=flip(left_analy_img,2);%镜像翻转
stat_r = regionprops(right_analy_img,'centroid');
stat_l = regionprops(left_analy_img,'centroid');
right_cen=[stat_r(1).Centroid(1),stat_r(1).Centroid(2)];
left_cen=[stat_l(1).Centroid(1),stat_l(1).Centroid(2)];
%右、左足中心坐标，x代表列，y代表行
a=right_cen(1);
b=right_cen(2);
p=left_cen(1);
q=left_cen(2);
analyzed_img=zeros(1,1);
k=0;analy_sum=0;
min.value=255;min.x=0;min.y=0;
max.value=-255;max.x=0;max.y=0;
for i=1:156
    for j=1:100
        if left_analy_img(floor(q)-78+i,floor(p)-50+j)==0||right_analy_img(floor(b)-78+i,floor(a)-50+j)==0
            %左右足对应点，若有一点为零，则分析后的图像该点为零，用于舍去周围环境区域以及两足之间无法对应上的区域的数据
            analyzed_img(i,j)=0;
        else
            analyzed_img(i,j)=left_analy_img(floor(q)-78+i,floor(p)-50+j)-right_analy_img(floor(b)-78+i,floor(a)-50+j);
            analy_sum=analy_sum+analyzed_img(i,j);k=k+1;%用于计算平均温度差
            if analyzed_img(i,j)<min.value
                min.value=analyzed_img(i,j);
                min.x=i;min.y=j;%矩阵中第x行第y列，绘图时相当于（y,x)处
            end  
            if analyzed_img(i,j)>max.value
                max.value=analyzed_img(i,j);
                max.x=i;max.y=j;
            end 
        end

    end
end
mat_analyzed_img=mat2gray(analyzed_img);
uint_analyzed_img=uint8(analyzed_img);%double转uint8
imwrite(uint_analyzed_img, strcat('footIR_',num2str(analysis_i),'不对称分析后的图像.png'));
%保存成png格式，从matlab左侧的当前文件夹看到的要比figure函数绘制的以及windows照片展示的要亮一点，不论是uint8格式，还是mat2gray格式
% figure(1)
% subplot(2,1,1);
% imshow(left_analy_img);
% subplot(2,1,2);
average=analy_sum/k;
figure(1);
subplot(2,1,1);
imshow(mat_analyzed_img);
hold on;
plot(min.y,min.x,'ro');%在图像标注时第一维相当于矩阵中的列，第二维相当于行
plot(max.y,max.x,'ro');
subplot(2,1,2);
imshow(uint_analyzed_img);
hold on;
plot(min.y,min.x,'ro');%在图像标注时第一维相当于矩阵中的列，第二维相当于行
plot(max.y,max.x,'ro');
end