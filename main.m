img_count=1;
for I=1:img_count
    %调用旋转函数，旋转左右足，垂直对齐，并保存
    my_seg(I);
    for J=1:2
        rotated_img=my_rotate(I,J);
        imwrite(rotated_img, strcat('footIR_',num2str(I),'旋转后的第',num2str(J), '幅图','.png')); %保存每张旋转后的图像
    end
    my_analysis(I);
end