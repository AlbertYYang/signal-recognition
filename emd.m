%emd.m�ļ�
% function imf = emd(x,times)

function imf=emd()
clear all
close all
clc
x= audioread('E:\������\singal\50power-1-all.wav',[1 327680]);% ��������
x=x(:,1);
times=4;
% Empiricial Mode Decomposition (Hilbert-Huang Transform)
% EMD�ֽ��HHT�任
% ����ֵΪcell���ͣ�����Ϊһ��IMF������IMF��...�����в�
x   = transpose(x(:));
imf = [];
while ~ismonotonic(x)&&size(imf,2)<=times
    x1 = x;
    sd = Inf;
    while (sd > 0.1) || ~isimf(x1)
        s1 = getspline(x1);         % ����ֵ����������
        s2 = -getspline(-x1);       % ��Сֵ����������
        x2 = x1-(s1+s2)/2;
       
        sd = sum((x1-x2).^2)/sum(x1.^2);
        x1 = x2;
    end
   
    imf{end+1} = x1;
    x          = x-x1;
end
imf{end+1} = x;
% �Ƿ񵥵�
function u = ismonotonic(x)
u1 = length(findpeaks(x))*length(findpeaks(-x));
if u1 > 0
    u = 0;
else
    u = 1;
end
% �Ƿ�IMF����
function u = isimf(x)
N  = length(x);
u1 = sum(x(1:N-1).*x(2:N) < 0);                     % �����ĸ���
u2 = length(findpeaks(x))+length(findpeaks(-x));    % ��ֵ��ĸ���
if abs(u1-u2) > 1
    u = 0;
else
    u = 1;
end
% �ݼ���ֵ�㹹����������
function s = getspline(x)
N = length(x);
p = findpeaks(x);
s = spline([0 p N+1],[0 x(p) 0],1:N);
function n = findpeaks(x)
% Find peaks. �Ҽ���ֵ�㣬���ض�Ӧ����ֵ�������
n    = find(diff(diff(x) > 0) < 0); % �൱���Ҷ��׵�С��0�ĵ�
u    = find(x(n+1) > x(n));
n(u) = n(u)+1;  