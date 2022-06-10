function [ cum_wealth, daily_incre_fact, daily_port_total] = SPO_kp_run( data,opts,market,market_vr)
%{
This function is part of the codes for the Adaptive Input and Composite Trend Representation (AICTR)[2]
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
data                      -data with price relative sequences
win_size                  -window size
tran_cost                 -transaction cost rate

Outputs:
cum_wealth                -cumulative wealths
daily_incre_fact          -daily increasing factors of AICTR
daily_port_total          -daily selected portfolios of AICTR

%}

if isfield(opts,'tran_cost')
    tran_cost = opts.tran_cost;         % -transaction cost rate
else
    tran_cost = 0;
end
if isfield(opts,'win_size')
    win_size = opts.win_size;           % -window size
else
    win_size = 5;
end

[T ,N]=size(data);
%predict rpr 
phi_t_hat = ones(1, N);

% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;

cum_wealth = ones(T, 1);
daily_incre_fact = ones(T, 1);
cum_rt_vector = ones(T,1);

daily_port = ones(N, 1)/N;  
weight2= ones(N, 1)/N;  
weight3 = ones(N, 1)/N;  

daily_port_total=ones(N, T)/N;
daily_port_o = zeros(N, 1);
daily_port_total_rpr=ones(N, T)/N;

datahat=ones(T, N,3);
datahat_center=ones(T, N,3)/N;


close_price = ones(T,N);
for i=2:T
    close_price(i,:)= close_price(i-1,:).*data(i,:);
end

run_ret=1;
cum_rt = 0;
for t = 1:T

    daily_port_total(:,t)=daily_port;
    daily_incre_fact(t, 1) = (data(t, :)*daily_port)*(1-tran_cost/2*sum(abs(daily_port-daily_port_o)));
    
%     new_return = cum_wealth(max(t-1,1), 1) * daily_incre_fact(t, 1);
%     if max_return < new_return
%         max_return = new_return;
%     end        
%     cur_mdd = (max_return - new_return)/max_return;
%     if mdd < cur_mdd
%         mdd = cur_mdd;
%     end   
    
    run_ret = run_ret * daily_incre_fact(t, 1);
    cum_rt = cum_rt + (daily_incre_fact(t, 1)-1);
    cum_rt_vector(t,1) = daily_incre_fact(t, 1)-1;
    cum_wealth(t) = run_ret;
    daily_port_o = daily_port.*data(t, :)'/(data(t, :)*daily_port);

     if(t<T)

       [daily_port_n,datahat,datahat_center,phi_tplus1_hat,weight1,weight2,weight3]=SPO_kpmodLR_fun(close_price,data,t+1,daily_port,datahat,datahat_center,phi_t_hat, win_size,opts,daily_port_total_rpr,weight2,weight3);
       phi_t_hat = phi_tplus1_hat;
       daily_port = daily_port_n;
       daily_port_total_rpr(:,t) = weight1;
    end
    

end

if cum_wealth(end)<10000
    fprintf('cw is\t%.2f\n',cum_wealth(end));
else
    fprintf('cw is\t%.2e\n',cum_wealth(end));
end

%avg_rt = cum_rt/size(data,1);%po daily averge return 
%fprintf('MER is \t%.5f\n',avg_rt-market);
%corv = cov(cum_rt_vector,market_vr);%corvaricance matrix
%beta = corv(1,2)/(std(market_vr)^2);
%alp = avg_rt - beta*market;
%se_alp = std(market_vr)/sqrt(size(data,1));
%p_value = alp/se_alp;
%fprintf('alp is \t%.5f\n',alp);
%fprintf('SR is \t%.5f\n',avg_rt/std(cum_rt_vector));
%fprintf('IR is \t%.5f\n',(avg_rt-market)/std(cum_rt_vector-market_vr));
%fprintf('MDD is \t%.5f\n',mdd);
%fprintf('CR is \t%.5f\n',run_ret^(252/T)-1);
%fprintf('\n');
%fprintf('p value is \t%.5f\n',p_value);
end