function [daily_port,datahat,datahat_center,EMA]=AICTR(close_price,data,tplus1,daily_port, datahat,datahat_center,EMA,win_size)
%{
This function is the main code for the Adaptive Input and Composite Trend Representation (AICTR)[2]
system. It exploits a set of RBFs with multiple trend representations, 
which improves the effectiveness and robustness in price prediction. 
Moreover, the input of the RBFs automatically switches to the best trend representation 
according to the recent investing performance of different price predictions.

For any usage of this function, the following papers should be cited as
reference:

[1] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. ¡°A peak price tracking 
based learning system for portfolio selection¡±, 
IEEE Transactions on Neural Networks and Learning Systems, 2017. Accepted.
[2] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang.  ¡°Radial basis functions 
with adaptive input and composite trend representation for portfolio selection¡±, 
IEEE Transactions on Neural Networks and Learning Systems, 2018. Accepted.
[3] Pei-Yi Yang, Zhao-Rong Lai*, Xiaotian Wu, Liangda Fang. ¡°Trend Representation 
Based Log-density Regularization System for Portfolio Optimization¡±,  
Pattern Recognition, vol. 76, pp. 14-24, Apr. 2018.

At the same time, it is encouraged to cite the following papers with previous related works:

[4] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra, ¡°Efficient
projections onto the \ell_1-ball for learning in high dimensions,¡± in
Proceedings of the International Conference on Machine Learning (ICML 2008), 2008.
[5] B. Li, D. Sahoo, and S. C. H. Hoi. Olps: a toolbox for on-line portfolio selection.
Journal of Machine Learning Research, 17, 2016.


Inputs:
close_price               -close price sequences
data                      -data with price relative sequences
tplus1                    -t+1
daily_port                -selected portfolio at time t
datahat                   -several trend representations at time t
datahat_center            -several trend representations that are
normalized to eligible portfolios at time t
EMA                       -exponential moving average at time t
win_size                  -window size


Output:
daily_port                -selected portfolio at time t+1
datahat                   -several trend representations at time t+1
datahat_center            -several trend representations that are
normalized to eligible portfolios at time t+1
EMA                       -exponential moving average at time t+1

%}
%{
epsilon=1000;% a parameter that controls the update step size
alpha=0.5;%the mixing parameter of EMA
sigmasquare=0.0025;%the scale parameter of the RBFs
%}
epsilon=1000;% a parameter that controls the update step size
alpha=0.5;%the mixing parameter of EMA
sigmasquare=0.0025;%the scale parameter of the RBFs

[T,nstk]=size(data);

EMA = alpha+(1-alpha)*EMA./data(tplus1-1, :);


if (tplus1 < win_size+2)
    SMA = data(tplus1-1, :);
    PP=data(tplus1-1,:);

else
    SMA = zeros(1, nstk);
    tmp_x = ones(1, nstk);
    for i = 1:win_size
        SMA = SMA + 1./tmp_x;
        tmp_x = tmp_x.*data(tplus1-i, :);
    end
    
    SMA = SMA*(1/win_size);



   closebefore=close_price((tplus1-win_size):(tplus1-1),:);
   closepredict=max(closebefore);   
   PP = closepredict./close_price(tplus1-1,:);
end

xhat=zeros(nstk,3);
xhat(:,1)=EMA';
xhat(:,2)=SMA';
xhat(:,3)=PP';



datahat(tplus1,:,:)=xhat;

xhat_simplex=zeros(nstk,3);

xhat_simplex(:,1) = simplex_projection_selfnorm2(xhat(:,1),1);
xhat_simplex(:,2) = simplex_projection_selfnorm2(xhat(:,2),1);
xhat_simplex(:,3) = simplex_projection_selfnorm2(xhat(:,3),1);

datahat_center(tplus1,:,:)=xhat_simplex;


if (tplus1 < win_size+2)
    rate=zeros(tplus1-1,3);
    for id=1:3
    rate(:,id)=diag(datahat_center(1:tplus1-1,:,id)*data(1:tplus1-1, :)');
    end
else
    rate=zeros(win_size,3);
    for id=1:3
    rate(:,id)=diag(datahat_center((tplus1-win_size):(tplus1-1),:,id)*data((tplus1-win_size):(tplus1-1), :)');
    end        
end
rate_score=min(rate)';
idx=find(rate_score==max(rate_score));
idx=idx(1);





ones_w=ones(1,3);
center=xhat_simplex;

bigA=xhat;

eunorm=diag((xhat_simplex(:,idx)*ones_w-center)'*(xhat_simplex(:,idx)*ones_w-center));


bigphi=exp(-eunorm/(2*sigmasquare));
%=================test the weight of new x_t+1

%=================
onesn=ones(nstk,1);

dee=(eye(nstk)-onesn*onesn'/(nstk))*(bigA*bigphi);

daily_port = daily_port+epsilon*dee/norm(dee);

daily_port = simplex_projection_selfnorm2(daily_port,1);





end
