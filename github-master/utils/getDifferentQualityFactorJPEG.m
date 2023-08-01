function [x] = getDifferentQualityFactorJPEG( tiffFileName )
%输入TIFF格式文件名，输出10~90量化因子的JPEG文件
Qf = 0;
for i = 1:9
    Qf = Qf + 10;
    ImgStr = tiffFileName;
    ImgName = [ImgStr,'_',num2str(Qf),'.jpg'];
    ImgData = imread(ImgStr,'tiff');
    imwrite(ImgData,ImgName,'JPEG','Quality',Qf);
end

end

