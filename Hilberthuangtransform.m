function HT=HILBERTHUANGTRANSF()
% clear all
% close all
% clc
% [x, Fs] = wavread('Hum.wav');
% Ts = 1/Fs;
% x = x(1:6000);
Ts = 0.001;
Fs = 1/Ts;
t=0:Ts:1;
x =2*sin(2*pi*100*t) +3* sin(2*pi*200*t) +4* sin(2*pi*300*t) + 0.1*randn(1, length(t));
% x0=audioread('D:\work50-all 00_03_25-00_03_55.wav',[1,3000]);
% x=x0(:,1);
imf = emd(x);
plot_hht(x,imf,1/Fs);
k = 4;
y = imf{k};
N = length(y);
t = 0:Ts:Ts*(N-1);
[yenvelope, yfreq, yh, yangle] = HilbertAnalysis(y, 1/Fs);
yModulate = y./yenvelope;
[YMf, f] = FFTAnalysis(yModulate, Ts);
Yf = FFTAnalysis(y, Ts);
figure
subplot(321)
plot(t, y)
title(sprintf('IMF%d', k))
xlabel('Time/s')
ylabel(sprintf('IMF%d', k));
subplot(322)
title(sprintf('IMF%d��Ƶ��', k))
xlabel('f/Hz')
ylabel('|IMF(f)|');
subplot(323)
plot(t, yenvelope)
title(sprintf('IMF%d�İ���', k))
xlabel('Time/s')
ylabel('envelope');
subplot(324)
plot(t(1:end-1), yfreq)
title(sprintf('IMF%d��˲ʱƵ��', k))
xlabel('Time/s')
ylabel('Frequency/Hz');
subplot(325)
plot(t, yModulate)
title(sprintf('IMF%d�ĵ����ź�', k))
xlabel('Time/s')
ylabel('modulation');
subplot(326)
plot(f, YMf)
title(sprintf('IMF%d�����źŵ�Ƶ��', k))
xlabel('f/Hz')
ylabel('|YMf(f)|');

%findpeaks.m�ļ�
function n = findpeaks(x)
% Find peaks. �Ҽ���ֵ�㣬���ض�Ӧ����ֵ�������
n    = find(diff(diff(x) > 0) < 0); % �൱���Ҷ��׵�С��0�ĵ�
u    = find(x(n+1) > x(n));
n(u) = n(u)+1;                      % ��1��������Ӧ����ֵ��
% ͼ�ν�����������
figure
subplot(611)
x = x(1:100);
plot(x, '-o')
grid on

subplot(612)
plot(1.5:length(x), diff(x) > 0, '-o')
grid on
axis([1,length(x),-0.5,1.5])

subplot(613)
plot(2:length(x)-1, diff(diff(x) > 0), '-o')
grid on
axis([1,length(x),-1.5,1.5])

subplot(614)
plot(2:length(x)-1, diff(diff(x) > 0)<0, '-o')
grid on
axis([1,length(x),-1.5,1.5])

n    = find(diff(diff(x) > 0) < 0);
subplot(615)
plot(n, ones(size(n)), 'o')
grid on
axis([1,length(x),0,2])

u    = find(x(n+1) > x(n));
n(u) = n(u)+1;
subplot(616)
plot(n, ones(size(n)), 'o')
grid on
axis([1,length(x),0,2])

%plot_hht.m�ļ�
function plot_hht(x,imf,Ts)
% Plot the HHT.
% :: Syntax
%    The array x is the input signal and Ts is the sampling period.
%    Example on use: [x,Fs] = wavread('Hum.wav');
%                    plot_hht(x(1:6000),1/Fs);
% Func : emd
% imf = emd(x);
for k = 1:length(imf)
    b(k) = sum(imf{k}.*imf{k});
    th   = unwrap(angle(hilbert(imf{k})));  % ��λ
    d{k} = diff(th)/Ts/(2*pi);          % ˲ʱƵ��
end
[u,v] = sort(-b);
b     = 1-b/max(b);                     % �����ͼ�����ȿ���
% Hilbert˲ʱƵ��ͼ
N = length(x);
c = linspace(0,(N-2)*Ts,N-1);           % 0:Ts:Ts*(N-2)
for k = v(1:2)                          % ��ʾ������������IMF��˲ʱƵ��
    figure
    plot(c,d{k});
    xlim([0 c(end)]);
    ylim([0 1/2/Ts]);
    xlabel('Time/s')
    ylabel('Frequency/Hz');
    title(sprintf('IMF%d', k))
end

% ��ʾ��IMF
M = length(imf);
N = length(x);
c = linspace(0,(N-1)*Ts,N);             % 0:Ts:Ts*(N-1)
for k1 = 0:4:M-1
    figure
    for k2 = 1:min(4,M-k1)
        subplot(4,2,2*k2-1)
        plot(c,imf{k1+k2})
        set(gca,'FontSize',8,'XLim',[0 c(end)]);
        title(sprintf('��%d��IMF', k1+k2))
        xlabel('Time/s')
        ylabel(sprintf('IMF%d', k1+k2));
       
        subplot(4,2,2*k2)
        [yf, f] = FFTAnalysis(imf{k1+k2}, Ts);
        plot(f, yf)
        title(sprintf('��%d��IMF��Ƶ��', k1+k2))
        xlabel('f/Hz')
        ylabel('|IMF(f)|');
    end
end
figure
subplot(211)
plot(c,x)
set(gca,'FontSize',8,'XLim',[0 c(end)]);
title('ԭʼ�ź�')
xlabel('Time/s')
ylabel('Origin');
subplot(212)
[Yf, f] = FFTAnalysis(x, Ts);
plot(f, Yf)
title('ԭʼ�źŵ�Ƶ��')
xlabel('f/Hz')
ylabel('|Y(f)|');

%emd.m�ļ�
function imf = emd(x)
% Empiricial Mode Decomposition (Hilbert-Huang Transform)
% EMD�ֽ��HHT�任
% ����ֵΪcell���ͣ�����Ϊһ��IMF������IMF��...�����в�
x   = transpose(x(:));
imf = [];
while ~ismonotonic(x)
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
%FFTAnalysis.m�ļ�
% Ƶ�׷���
function [Y, f] = FFTAnalysis(y, Ts)
Fs = 1/Ts;
L = length(y);
NFFT = 2^nextpow2(L);
y = y - mean(y);
Y = fft(y, NFFT)/L;
Y = 2*abs(Y(1:NFFT/2+1));
f = Fs/2*linspace(0, 1, NFFT/2+1);

%HilbertAnalysis.m�ļ�
% Hilbert����
function [yenvelope, yf, yh, yangle] = HilbertAnalysis(y, Ts)
yh = hilbert(y);
yenvelope = abs(yh);                % ����
yangle = unwrap(angle(yh));         % ��λ
yf = diff(yangle)/2/pi/Ts;          % ˲ʱƵ��