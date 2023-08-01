function [x] = getDifferentQualityFactorJPEG( tiffFileName )
%����TIFF��ʽ�ļ��������10~90�������ӵ�JPEG�ļ�
Qf = 0;
for i = 1:9
    Qf = Qf + 10;
    ImgStr = tiffFileName;
    ImgName = [ImgStr,'_',num2str(Qf),'.jpg'];
    ImgData = imread(ImgStr,'tiff');
    imwrite(ImgData,ImgName,'JPEG','Quality',Qf);
end

end

