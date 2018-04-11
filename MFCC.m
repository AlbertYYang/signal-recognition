% close all
% clear all
% clc
% wav= audioread('work50-1-all 00_00_00-00_00_30.wav',[1 307712]);
function Z=cood1(wav,dim)
% eg. 200���ļ� i_files= 1:200
% 307712����ȡ�������������ƶ�ȡ�ĳ��ȣ�Լ28s��
% Ҫ��ȡ��MFCCϵ������
wav=wav(:,dim);

num_ceps_coeffs = 14;
c.fs = 11025;  %����Ƶ��
% ����ÿ֡��С��������������
c.seg_size = 1024; 
c.hop_size = 512; %% c.seg_size-��������=c.hop_size 
% ֡������
num_segments = floor((length(wav)-c.seg_size)/c.hop_size)+1;           
% ��ʼ�������׾���
P = zeros(c.seg_size/2+1,num_segments); 
% ���ô�����
c.w = 0.5*(1-cos(2*pi*(0:c.seg_size-1)/(c.seg_size-1)))';%����������
%size(c.w)
% ��֡��FFT            
for i_p = 1:num_segments,
    idx = (1:c.seg_size)+(i_p-1)*c.hop_size;       
    x = abs(fft(wav(idx).*c.w)/sum(c.w)*2).^2;
    
    P(:,i_p) = x(1:end/2+1);%����ʵ���о���ֻ�õ��߹�����
   
end  

c.num_filt = 36; %% MelƵ����
f = linspace(0,c.fs/2,c.seg_size/2+1);%��ʼƽ������f
%%
mel = log(1+f/700)*1127.01048; %1127.01048=2595/log10 ,Matlab��log=ln

%%
mel_idx = linspace(0,mel(end),c.num_filt+2);%��ʼƽ������mel��38���㣩
f_idx = zeros(c.num_filt+2,1);
for i=1:c.num_filt+2,
%% f_idx(i)�����mel����mel_idx(i)�����Ԫ�صĵ�ַ
   [tmp, f_idx(i)] = min(abs(mel - mel_idx(i)));%���Ƶ�ƽ������       
end
%%
freqs = f(f_idx);
h = 2./(freqs(3:c.num_filt+2)-freqs(1:c.num_filt));%%���ǵĸ߶�
c.mel_filter = zeros(c.num_filt,c.seg_size/2+1);

for i=1:c.num_filt,
  c.mel_filter(i,:) =(f > freqs(i) & f <= freqs(i+1)).* ...
                h(i).*(f-freqs(i))/(freqs(i+1)-freqs(i)) + ...
                (f > freqs(i+1) & f < freqs(i+2)).* ...
                h(i).*(freqs(i+2)-f)/(freqs(i+2)-freqs(i+1));
            M = zeros(c.num_filt,num_segments);  %��ʼ��
end
for i_m = 1:num_segments,
    M(:,i_m) = c.mel_filter*P(:,i_m);% ͨ�������˲���
end

% �������任
%M(M<1)=1;
M = 10*log(M);
% min(P(:))
% min(M(:))
% return
%DCT����
c.DCT = 1/sqrt(c.num_filt/2) * ...
cos((0:num_ceps_coeffs-1)'*(0.5:c.num_filt)*pi/c.num_filt);
c.DCT(1,:) = c.DCT(1,:)*sqrt(2)/2;
c.DCT;
%%��ɢ���ұ任
mfcc= c.DCT * M;
ncentres = 16;% ��˹��������
input_dim = 16; %����ά��
Z=mfcc';

% gmm(Z,16);

% % ���û��ģ��
% mix = gmm(input_dim, ncentres, 'diag');
% % ������������
% siz=600;
% features = zeros(siz,input_dim);
%  for k=1:siz
%    for j=1:input_dim
%         features(k,j)=data.feat.mfcc(i_files,j,k);
%     end
% end
% % ��ʼ��ģ�Ͳ���
% mix = gmminit(mix, features, options);
% options(14) = 20;% ��������.
% [mix, options, errlog]=gmmem(mix, features, options);
% Gmmdata(i_files)=mix;

