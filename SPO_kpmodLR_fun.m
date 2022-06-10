function [daily_port,datahat,datahat_center,phi_tplus1_hat,weight1,weight2,weight3]=SPO_kpmodLR_fun(close_price,data,tplus1,daily_port, datahat,datahat_center,phi_t_hat,win_size,opts,daily_port_total,weight2,weight3)
%{
This function is the main code for the Adaptive Input and Composite Trend Representation (AICTR)[2]
system. It exploits a set of RBFs with multiple trend representations, 
which improves the effectiveness and robustness in price prediction. 
Moreover, the input of the RBFs automatically switches to the best trend representation 
according to the recent investing performance of different price predictions.

For any usage of this function, the following papers should be cited as
reference:

[1] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. “A peak price tracking 
based learning system for portfolio selection”, 
IEEE Transactions on Neural Networks and Learning Systems, 2017. Accepted.
[2] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang.  “Radial basis functions 
with adaptive input and composite trend representation for portfolio selection”, 
IEEE Transactions on Neural Networks and Learning Systems, 2018. Accepted.
[3] Pei-Yi Yang, Zhao-Rong Lai*, Xiaotian Wu, Liangda Fang. “Trend Representation 
Based Log-density Regularization System for Portfolio Optimization”,  
Pattern Recognition, vol. 76, pp. 14-24, Apr. 2018.

At the same time, it is encouraged to cite the following papers with previous related works:

[4] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra, “Efficient
projections onto the \ell_1-ball for learning in high dimensions,” in
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
% a parameter that controls the update step size

theta = 0.8; 			  % -mixing parameter
q1 = 0.1;% local weighted parameter
lambda = 0.7;%L1 regurlation strength
bigphi = zeros(3,1);
eta_ktpt = 60000;

[T,nstk]=size(data);
x_t = data(tplus1-1,:);
%EMA = alpha+(1-alpha)*EMA./data(tplus1-1, :);

%get RPR
gamma_tplus1 = theta*x_t./(theta*x_t+phi_t_hat);  					
phi_tplus1_hat = gamma_tplus1+(1-gamma_tplus1).*(phi_t_hat./x_t); 

[weight1, ~] = RPRT(data(1:tplus1-1,:), phi_t_hat, daily_port_total');
[weight2]=weighted_dayweight_ridge(close_price,data,tplus1,weight2, win_size);
[weight3]=PPT(close_price,data,tplus1,weight3, win_size);

if (tplus1 < win_size+2)
    SMA = data(tplus1-1, :);
    PP=data(tplus1-1,:);
    LRL = data(tplus1-1,:);
else
    SMA = zeros(1, nstk);
    tmp_x = ones(1, nstk);
    for i = 1:win_size
        SMA = SMA + 1./tmp_x;
        tmp_x = tmp_x.*data(tplus1-i, :);
    end
    
    SMA = SMA*(1/win_size);
    %caculate PP
    closebefore=close_price((tplus1-win_size):(tplus1-1),:);
    closepredict=max(closebefore);   
    PP = closepredict./close_price(tplus1-1,:);
    
    %caculate LRL
    d = 2*(1-q1)/(win_size-1); % common difference
    W = diag( q1:d:q1+(win_size-1)*d );
    X = [ones(win_size,1)  (1 :win_size)'];
    Y=closebefore;
    wt = (X'*W*X+lambda*eye(2))\(X'*W*Y);
    Rpredict= [1 win_size+1]*wt;
    Rpredict = (Rpredict+closepredict)/2;
    LRL = Rpredict./close_price(tplus1-1,:); % future price relative prediction


end

xhat=zeros(nstk,3);
xhat(:,1)=phi_tplus1_hat';
xhat(:,2)=LRL';
xhat(:,3)=PP';
datahat(tplus1,:,:)=xhat;

xhat_simplex=zeros(nstk,3);
xhat_simplex(:,1) =  weight1;
xhat_simplex(:,2) = weight2;
xhat_simplex(:,3) = weight3;
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

mean_center = mean(xhat_simplex(:,idx));

for i=1:3
    mean_xhat_simplex = mean(xhat_simplex(:,i));
    x = [(xhat_simplex(:,idx)-mean_center)' ;(xhat_simplex(:,i)-mean_xhat_simplex)'];
    bigphi(i)=1-pdist(x,'cosine');
end


%{
for i=1:3
    x = [(xhat_simplex(:,idx))' ;(xhat_simplex(:,i))'];
    bigphi(i)=1-pdist(x,'cosine');
end
%}

bigA=xhat;
onesn = ones(nstk,1);

%=================test the weight of new x_t+1
x_tp1_hat = bigA*bigphi;
%=================
x_tp1_norm = x_tp1_hat - mean(x_tp1_hat);
daily_port = daily_port + eta_ktpt*diag(phi_tplus1_hat')*x_tp1_norm;

daily_port = simplex_projection_selfnorm2(daily_port,1);


end
