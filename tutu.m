close all
clear all
clc
%%
data1=input('���÷�������1��power->0 work->1��\n');
data2=input('���÷�������2��power->0 work->1��\n');
MM=307712;
[X,mx1,nx1] = wenjian( data1,MM );
[Y,my1,ny1] = wenjian( data2,MM );
fenleiqi=input('������ѡ��1.fcm 2.svm�� \n');
wd1=input('���ӻ�ά��1 \n');
wd2=input('���ӻ�ά��2 \n');
[mx,nx]=size(X);
[my,ny]=size(Y);
D=[X;Y];
%----------------------------------------------------
% D=load('H:\LEdiwei\dataLEw50-p80.dat');
% [Dm,Dn]=size(D);
% mx=Dm/2;
% my=Dm/2;
% nx=Dn;
% ny=Dn;
% mx1=mx/7;
% nx1=nx;
% my1=my/7;
% ny1=ny;
% D=((mapminmax(D')+1)/2)';
% X=D(1:mx,:);
% Y=D(mx+1:mx+my,:);
%%
if fenleiqi==1
[center, U, obj_fcm] = FCMClust(D, 2);
 class1=find(U(1,:)==max(U));
 class2=find(U(2,:)==max(U));
 m1=1:mx;
 n1=1:mx+my; %%%%%%%%%%
 n1(1:mx)=0;
 m2=intersect(class1,m1);n2=intersect(class2,m1);
 m3=intersect(class1,n1);n3=intersect(class2,n1);
% length(m2),length(n2),length(m3),length(n3)
   if length(m2)>length(m3)%&length(m3)>length(n3)
     acc=(length(m2)/length(class1)+length(n3)/length(class2))/2;
%      elseif length(m2)>length(n2)&length(m3)<=length(n3)
%       acc=(length(m2)/(mx)+length(n3)/(mx))/2;
%       elseif length(m2)<=length(n2)&length(m3)>length(n3)
%       acc=(length(n2)/(mx)+length(m3)/(mx))/2;
       else
     acc=(length(m3)/length(class1)+length(n2)/length(class2))/2;
    end
fprintf('������ȷ�ʣ�%f ',acc)
figure(1)
plot(X(:,wd1),X(:,wd2),'r o'),hold on
plot(Y(:,wd1),Y(:,wd2),'b o')
title('ԭʼ���ݼ�')
figure(2)
plot(D(class1,wd1),D(class1,wd2),'r o'),hold on
plot(D(class2,wd1),D(class2,wd2),'b o'),
title('FCM������')
%%
 else if fenleiqi==2
        
 
         TEST1=input('���Լ�1��1-7�� \n');
         TEST2=input('���Լ�2��1-7�� \n');
         tc=input('�ֵ��Σ�1����ϸ���Σ�2�� \n');
         ESP=input('����Ӧ��� \n');
         
     N(1:mx-mx1,:)=double(D(1:mx-mx1,:));
     N(mx-mx1+1:mx-mx1+my-my1,:)=double(D(mx+1:mx+my-my1,:));
% N(7201:10800,:)=C;
     M(1:mx-mx1,:)=ones(mx-mx1,1);
     M(mx-mx1+1:mx-mx1+my-my1,:)=-1*ones(my-my1,1);
% M(7201:10800,:)=zeros(3m0,1);
ii=1;
jj=1;
while ii<=(mx/mx1)
       if  TEST1==ii
           T1=X((ii-1)*mx1+1:ii*mx1,:);
           break
       else
           ii=ii+1;
       end
end
while jj<=(my/my1)
       if  TEST2==jj
           T2=Y((jj-1)*my1+1:jj*my1,:);
           break
       else
           jj=jj+1;
       end
end
     t(1:mx1,:)=double(T1);                     %���Լ�ѡ
     t(mx1+1:mx1+my1,:)=double(T2);  
%      t=((mapminmax(t')+1)/2)';                  %��һ��
% t(2*m0+1:3*m0,:)=Y7;
     l(1:mx1,:)=ones(mx1,1);
     l(mx1+1:mx1+my1,:)=-1*ones(my1,1);
% l(2*m0+1:3*m0,:)=zeros(m0,1);
%%
%����
if tc==1
  
  [bestacc,bestc,bestg] = SVMcgForclass(M,N,-4,1,-4,2);
  disp('��ӡ����ѡ����');
  str = sprintf( 'Best Cross Validation Accuracy = %g%% Best c = %g Best g = %g',bestacc,bestc,bestg);
  disp(str);
else if tc==2
  [bestacc,bestc,bestg] = SVMcgForclass(M,N,-2,0,-2,2);
  disp('��ӡ����ѡ����');
  str = sprintf( 'Best Cross Validation Accuracy = %g%% Best c = %g Best g = %g',bestacc,bestc,bestg);
  disp(str);
 
  [bestacc,bestc,bestg] = SVMcgForclass(M,N,bestc-1,bestc+0.5,bestg-0.5,bestg+0.5,3,0.5,0.5,0.9);
  disp('��ӡ��ϸѡ����');
  str = sprintf( 'Best Cross Validation Accuracy = %g%% Best c = %g Best g = %g',bestacc,bestc,bestg);
  disp(str);
    end
end
%%
emd = [' -c ',num2str( bestc ),' -g ',num2str( bestg )];
model = libsvmtrain(M,N,emd );
[predict_label, accuracy, dec_values] = libsvmpredict(l, t, model);
total = length(l);
right = sum(predict_label == l);
disp('��ӡ���Լ�����׼ȷ��');
str = sprintf( 'Accuracy = %g%% (%d/%d)',accuracy(1),right,total);
disp(str);
%%
%��ȡ������
nr1=find(predict_label==1);
nr2=find(predict_label==-1);
r1=t(nr1,:);
r2=t(nr2,:);
figure()
plot(T1(:,wd1),T1(:,wd2),'r o'),hold on
plot(T2(:,wd1),T2(:,wd2),'b o')
title('���Լ�')
figure()
plot(T1(:,wd1),T1(:,wd2),'r o'),hold on
plot(T2(:,wd1),T2(:,wd2),'b o'),hold on
plot(r1(:,wd1),r1(:,wd2),'r .'),hold on
plot(r2(:,wd1),r2(:,wd2),'b .')
title('���Լ�������')
%%
%��ȡ֧������
[m,n]=size(model.SVs);
ACC=accuracy;
for i=1:m
    for j=1:n
     S(i,j)=full(model.SVs(i,j));
    end
end

kk=1;
k=1;
b=0;
bb=1;
while(kk<=1000)

  for k=1:m
   if abs(model.sv_coef(k))>b
        P(k,:)=S(k,:);
   else
        P(k,:)=zeros(1,size(S,2));
   end
  end
  P(all(P==0,2),:)=[]; 
   ll=size(P,1);
   esp=abs(bb-ll);
   if esp<ESP
        break
   else bb=ll;    b=b-0.001;
   kk=kk+1;
   end
end
%----------------------------------------------
% figure()
% plot(X(:,wd1),X(:,wd2),'r o'),hold on
% plot(Y(:,wd1),Y(:,wd2),'b o')
% hold on
% plot(P(:,wd1),P(:,wd2),'g .')
% title('ѵ�����µ�֧�������ֲ����')
%----------------------------------------------
% for i=1:size(X,2)-1
%     for j=i+1:size(X,2)
%         plot(X(:,i),X(:,j),'r o'),hold on
%         plot(Y(:,i),Y(:,j),'b o'),hold on
%         plot(P(:,i),P(:,j),'g .')
%         title(['i= ',num2str(i), ' , j= ',num2str(j)])
%         pause
%         hold off
%     end
% end
  end
end

        

% % scatter(D(:,3),D(:,2),'r'),hold on
% figure(1)
% scatter(D(1:6*m0,2),D(1:6*m0,3),'r'),hold on
% scatter(D(6*m0+1:12*m0,2),D(6*m0+1:12*m0,3),'b')
% % scatter(C(:,3),C(:,5),'g')
%  [center, U, obj_fcm] = FCMClust(D, 2);
%  class1=find(U(1,:)==max(U));
%  class2=find(U(2,:)==max(U));
%  m1=1:6*m0;
%  n1=1:12*m0;
%  n1(1:6*m0)=0;
%   m2=intersect(class1,m1);n2=intersect(class2,m1);
% m3=intersect(class1,n1);n3=intersect(class2,n1);
% % length(m2),length(n2),length(m3),length(n3)
%  if length(m2)>length(n2)&length(m3)>length(n3)
%      acc=(length(m2)+length(m3))/(12*m0);
%  elseif length(m2)>length(n2)&length(m3)<=length(n3)
%       acc=(length(m2)/(6*m0)+length(n3)/(6*m0))/2;
%  elseif length(m2)<=length(n2)&length(m3)>length(n3)
%       acc=(length(n2)/(6*m0)+length(m3)/(6*m0))/2;
%  else
%      acc=(length(n2)/(6*m0)+length(n3)/(6*m0))/2;
%  end  
% % sum(class1)/(3m0*3m0+1/2),sum(class2)/(3m0*3m0+1/2)
% % 
% % sum(class1)/(7200*7201/2),sum(class2)/(7200*7201/2)
% figure(2)
% scatter(D(class1,2),D(class1,3),'+'),hold on
% scatter(D(class2,2),D(class2,3),'O'),
% % return
% model= libsvmtrain(M,N,0);
% [predict_label, accuracy, dec_values] = libsvmpredict(l, t, model);
