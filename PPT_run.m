function [ cum_wealth, daily_incre_fact, daily_port_total] = PPT_run(data, win_size, tran_cost,market,market_vr)
%{
This function is part of the codes for the Peak Price Tracking (PPT)[1]
system. It aggressively tracks the increasing power of different assets
such that the better performing assets will receive more investment.

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
data                      -data with price relative sequences
win_size                  -window size
tran_cost                 -transaction cost rate

Outputs:
cum_wealth                -cumulative wealths
daily_incre_fact          -daily increasing factors of PPT
daily_port_total          -daily selected portfolios of PPT

%}



[T N]=size(data);


cum_wealth = ones(T, 1);
daily_incre_fact = ones(T, 1);


daily_port = ones(N, 1)/N;  
daily_port_total=ones(N, T)/N;
daily_port_o = zeros(N, 1);
cum_rt_vector = ones(T,1);
% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;


close_price = ones(T,N);
for i=2:T
    close_price(i,:)= close_price(i-1,:).*data(i,:);
end




run_ret=1;
cum_rt = 0;
for t = 1:T

    daily_port_total(:,t)=daily_port;
    daily_incre_fact(t, 1) = (data(t, :)*daily_port)*(1-tran_cost/2*sum(abs(daily_port-daily_port_o)));

    new_return = cum_wealth(max(t-1,1), 1) * daily_incre_fact(t, 1);
    if max_return < new_return
        max_return = new_return;
    end        
    cur_mdd = (max_return - new_return)/max_return;
    if mdd < cur_mdd
        mdd = cur_mdd;
    end   
 
    run_ret = run_ret * daily_incre_fact(t, 1);
    cum_rt = cum_rt + (daily_incre_fact(t, 1)-1);
    cum_rt_vector(t,1) = daily_incre_fact(t, 1)-1;
    cum_wealth(t) = run_ret;
    

    daily_port_o = daily_port.*data(t, :)'/(data(t, :)*daily_port);


     if(t<T)
       [daily_port_n]=PPT(close_price,data,t,daily_port, win_size);
       

       daily_port = daily_port_n;
    
    end
    

end
%{
if cum_wealth(end)<10000
    fprintf('CW is \t %.2f \n',cum_wealth(end));
else
    fprintf(' CW is\t %.2e \n',cum_wealth(end));
end
%}
avg_rt = cum_rt/size(data,1);%po daily averge return 
%fprintf('MER is \t%.5f\n',avg_rt-market);
corv = cov(cum_rt_vector,market_vr);%corvaricance matrix
beta = corv(1,2)/(std(market_vr)^2);
alp = avg_rt - beta*market;
se_alp = std(market_vr)/sqrt(size(data,1));
p_value = alp/se_alp;
%fprintf('alp is \t%.5f\n',alp);
%fprintf('SR is \t%.5f\n',avg_rt/std(cum_rt_vector));
%fprintf('IR is \t%.5f\n',(avg_rt-market)/std(cum_rt_vector-market_vr));
%fprintf('MDD is \t%.5f\n',mdd);
%fprintf('CR is \t%.5f\n',run_ret^(252/T)-1);
%fprintf('\n');
%fprintf('p value is \t%.5f\n',p_value);

end