function [rotate_un_img,MIN,MAX,average]=my_rotate(rotate_i,rotate_j)
%ROTATE Rotate the clipped grayscale image of the foot
% 
rotate_a=strcat('./footIR_',num2str(rotate_i),'第',num2str(rotate_j), '幅图','.png');
cutted_img=imread(rotate_a);
% figure(5);
% subplot(1,3,1);
% imshow(cutted_img);
%%
immax=-255;immin=255;rotate_k=0;rotate_sum=0;
[M, N, C] = size(cutted_img); %获取图像的大小
for i = 1:M
    for j = 1:N
        if cutted_img(i,j)~=0
            rotate_sum=rotate_sum+double(cutted_img(i,j));rotate_k=rotate_k+1;%用于计算平均温度差
            if cutted_img(i,j)>immax
                immax=cutted_img(i,j);
            end
            if cutted_img(i,j)<immin
                immin=cutted_img(i,j);
            end
        end
    end
end
[miny,minx]=find(cutted_img==immin);
MIN=[miny,minx];
[maxy,maxx]=find(cutted_img==immax);
MAX=[maxy,maxx];
average=rotate_sum/rotate_k;
%%
cutted_Ibw = imbinarize(cutted_img,0.1);%转二值图像(要设置level)
% subplot(1,3,2);
% imshow(cutted_Ibw);
stat = regionprops(cutted_Ibw,'centroid');

hold on;
for x = 1: numel(stat)
    plot(stat(x).Centroid(1),stat(x).Centroid(2),'ro');
end
%cen_x=floor(stat(1).Centroid(1));%质心 x坐标向下取整，在矩阵（图像）里代表的是列
cen_y=floor(stat(1).Centroid(2));%质心 y坐标向下取整，在矩阵（图像）里代表的是行
row_codi=cen_y;%行 第124行（第67列是质心）
begin=zeros(1,1);%存储各行左边界（1是随便设的大小）
terminate=zeros(1,1);%存储各行右边界
k=1;

%%
while(true)

    %判断该行是否全部为零，若是，退出循环
    if sum(cutted_img(row_codi,:))== 0
        break; 
    end 
    %遍历各列
    for col_codi=1:129
        %为左边界，记录
        if cutted_img(row_codi,col_codi)==0&&cutted_img(row_codi,col_codi+1)~=0
            begin(k)=col_codi+1;
        else
            %为右边界，记录，并k++，以记录下一行的边界所在列
            if cutted_img(row_codi,col_codi)~=0&&cutted_img(row_codi,col_codi+1)==0
                terminate(k)=col_codi;k=k+1;  
            end
        end
    end
    %遍历下一行
    row_codi=row_codi+1;
end
%%
% x_size=size(begin);
x_fit=1:size(begin,2);%获取行数，并作为拟合曲线x轴
t_b=(terminate-begin)/2+begin;%获取每行中心，并作为拟合曲线y轴
%(terminate-begin)/2+begin，需加begin
line=polyfit(x_fit,t_b,1);%***最后十几个点误差很大，考虑如何舍去***
% subplot(1,3,3);
% plot(x_fit,t_b,'*',x_fit,polyval(line,x_fit));
fit_slope=line(1:1);%获得斜率
angle=atan(fit_slope);%弧度
anglout = rad2deg(angle);%角度
rotate_un_img = imrotate(cutted_img,-anglout,'bilinear','crop');%imrotate函数的输入需是角度，不是弧度 
%***旋转后图像会填充空洞，数据会失真，怎么解决？考虑以5*5矩阵等，作为不对称分析的最小单位，减小误差，
%毕竟单个点已经无法准确代表该处温度值，但既然目测图像变化不大，就说明填充算法没有过多改变该点附近的温度信息，还是可以用来比较的***%
% figure(6);
% imshow(rotate_un_img);
end