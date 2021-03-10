%% Grid for tech shock, z,
% by using Tauchen's method of finite state  Markov approximation
% YJ: 参考Comp Econ郭老师的课件Dynamic Labor Supply
m=3;
w=2*m*sigma/(Z-1); % YJ: node之间的距离
lnz=(-m*sigma+a):w:(m*sigma+a); % YJ: -m*sigma+a是下界点，m*sigma+a是上界点
% YJ: 问题，为什么上式是a而不是mu_y (y's expectation)?
z=exp(lnz);

%Markov transition matrix
p=zeros(Z);

%See formula on notes
% YJ: 这里是计算并填入transition matrix的各个元素
% YJ: 也参考郭老师的课件Dynamic Labor Supply（和这里的具体式子有小差异）
p(:,1)=normcdf(((lnz(1)+w/2)*ones(Z,1)-ro*lnz')/stde,0,1);
p(:,Z)=ones(Z,1)-normcdf(((lnz(Z)-w/2)*ones(Z,1)-ro*lnz')/stde,0,1);
for j=2:(Z-1)
    p(:,j)=normcdf(((lnz(j)+w/2)*ones(Z,1)-ro*lnz')/stde,0,1)-...
        normcdf(((lnz(j)-w/2)*ones(Z,1)-ro*lnz')/stde,0,1);
end

% % YJ code begins
% p = eye(Z);
% % YJ code ends

% Initial distribution (assumed to be uniform)
% YJ: 这就是Edmond slide里的g_i, the initial dist. of productivity
% YJ: 这的确是uniform dist., 注意inidis是概率分布而非z的具体取值，z的取值还是z1到z21，
% YJ: 而且取每个值的概率相同
inidis=ones(1,Z)./Z;

% YJ code begins
% inidis(3) = inidis(3) + 0.02;
% inidis(4) = inidis(4) - 0.01;
% inidis(6) = inidis(6) - 0.01;
% YJ code ends

%% Grid points of n
% with the largest to be 5000
nmax=5000;
n=0:nmax/(N-1):nmax; % YJ: 这是employment nodes