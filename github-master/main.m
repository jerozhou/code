clear;clc;dbstop if error;tic;
addpath(genpath('..\..\utils\'));
addpath(genpath('..\..\image\'));
addpath(genpath(pwd));
name_cover = 'Lena_70.jpg';
%%  ´ýÇ¶Êý¾Ý
len_secret =10000;     
secret = round(rand(1,len_secret)*1);
[File_Size,PSNR,runtime,ssim] = RDH_Zhou(name_cover,secret);