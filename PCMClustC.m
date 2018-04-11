function [center, U, obj_pcm] = PCMClustC(data,cluster_n,options)
% INPUT
% data ------------- dataset(datasize*attributesize)
% cluster_n----------- number of cluster
% options     ---- cell��1*2����
%       options{1}   :  initial center of cluster                    
%       options{2}(1):  exponent for the matrix U             (default: 2.0)
%       options{2}(2):  maximum number of iterations          (default: 100)
%       options{2}(3):  minimum amount of improvement         (default: 1e-5)
%       options{2}(4):  info display during iteration         (default: 1)
% OUTPUT
% center-------------  center of cluster
% U------------------  probability matrix
% obj_pcm------------  object function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all
% close all
% clc
% mu = [2 3];
% SIGMA = [1 0;0 7];
% r1 = mvnrnd(mu,SIGMA,100);
% mu = [10 15];
% SIGMA = [2 0;0 5];
% r2 = mvnrnd(mu,SIGMA,100);
% scatter(r1(:,1),r1(:,2),'r'),hold on
% scatter(r2(:,1),r2(:,2),'b')
% data=[r1;r2];
% options={[2 3;10 15],[]};
% %----------------------------
% cluster_n=2;
% options=[2 100 1e-5 1];
% expo = options(1);          % ���ܶȾ���U��ָ��
% max_iter = options(2);		% ���������� 
% min_impro = options(3);		% ���ܶ���С�仯��,������ֹ����
% display = options(4);		% ÿ�ε����Ƿ������Ϣ��־ 
% obj_fcm = zeros(max_iter+1, 1);	% ��ʼ���������obj_fcm
% [data_n,in_n]=size(data);
%  U = 0.5*ones(cluster_n, data_n);
%  center=[2 3;10 15];
% %----------------------------
%---------------------------------------------
%---------------------------------------------
[data_n,in_n]=size(data);
default_options = [2;	                  % �����Ⱦ���U��ָ��
                      100;                % ���������� 
                      1e-5;               % ��������С�仯��,������ֹ����
                      1];                 % ÿ�ε����Ƿ������Ϣ��־
if  length(options{2})~=4;
	options{2} = default_options;
end     %������options������ʱ������
%��options �еķ����ֱ�ֵ���ĸ�����;
expo = options{2}(1);          % �����Ⱦ���U��ָ��
max_iter = options{2}(2);		% ���������� 
min_impro = options{2}(3);		% ��������С�仯��,������ֹ����
display = options{2}(4);		% ÿ�ε����Ƿ������Ϣ��־ 
obj_pcm = zeros(max_iter, 1);	% ��ʼ���������obj_fcm
center=options{1};
U=0.5*ones(cluster_n, data_n);
%---------------------------------------------------
%---------------------------------------------------
i=2;
while i<=max_iter
    %�ڵ�k��ѭ���иı��������ceneter,�ͷ��亯��U��������ֵ;
mf = U.^expo;       % �����Ⱦ������ָ��������
for k = 1:cluster_n, % ��ÿһ����������
    dist(k, :) = sqrt(sum(((data-ones(size(data,1),1)*center(k,:)).^2)',1));
end    % ����������
ata=sum(mf.*dist.^2,2)./sum(mf,2);      %����ϵ��ata
obj_pcm(i) = sum(sum((dist.^2).*mf))+sum(ata.*sum((ones(cluster_n,data_n)-U).^expo,2));  % ����Ŀ�꺯��ֵ  
U =ones(cluster_n,data_n)./(ones(cluster_n,data_n)+(dist.^2./repmat(ata,[1,data_n])).^(1/(expo-1)));   % �����µĿ��ܶȾ���
center = (U.^expo*data)./repmat(sum(U.^expo,2),[1,in_n]); % �¾�������(5.4)ʽ
	if display
		fprintf('PCM:Iteration count = %d, obj. pcm = %f\n', i, obj_pcm(i));
	end
	% ��ֹ�����б�

		if abs(obj_pcm(i) - obj_pcm(i-1)) < min_impro
            break;      
        end
    i=i+1;
%    pause(0.001)

end

iter_n = i;	% ʵ�ʵ�������
obj_pcm(iter_n+1:max_iter) = [];
