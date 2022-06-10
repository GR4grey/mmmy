function [cum_wealth, daily_incre_fact, daily_port_total] = RPRT_run(data,market,market_vr,tran_cost)
%{
This function is the main code for the Reweighted Price Relative Tracking System for Automatic 
Portfolio Optimization (RPRT)[4]system. It exploits a reweighted price relative, which 
automatically assigns separate weights to the price relative predictions according to 
each asset¡¯s performance, and these weights will also be automatically updated.

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
[4]Zhao-Rong Lai, Pei-Yi Yang,  Liangda Fang and Xiaotian Wu.
 ¡°Reweighted Price Relative Tracking System for Automatic Portfolio Optimization¡±. 
IEEE Transactions on Systems, Man, and Cybernetics: Systems, 2018. Accepted.
[5]Zhao-Rong Lai, Pei-Yi Yang, Xiaotian Wu and Liangda Fang. ¡°A kernel-based trend pattern 
tracking system for portfolio optimization¡±, Data Mining and Knowledge
Discovery, 2018. Accepted.


At the same time, it is encouraged to cite the following papers with previous related works:

[6] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra, ¡°Efficient
projections onto the \ell_1-ball for learning in high dimensions,¡± in
Proceedings of the International Conference on Machine Learning (ICML 2008), 2008.
[7] B. Li, D. Sahoo, and S. C. H. Hoi. Olps: a toolbox for on-line portfolio selection.
Journal of Machine Learning Research, 17, 2016.

Inputs:
data                      -data with price relative sequences

Outputs:
cum_wealth                -cumulative wealths
daily_incre_fact          -daily increasing factors of RPRT
daily_port_total          -daily selected portfolios of RPRT
%}

%% Parameter Setting
% -transaction cost rate


%% Variables Inital
cum_rt = 0;

[n, m] = size(data);
cum_rt_vector = ones(n,1);
cum_wealth = ones(n, 1);
daily_incre_fact = ones(n, 1);
daily_port_total = zeros(n, m);
b_t_hat = ones(m, 1)/m;  				% Portfolio weights, starting with uniform portfolio
b_tminus1_hat = zeros(m, 1); 			% Last closing price adjusted portfolio
phi_tminus1_hat = ones(1, m);

% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;
%% main
for t = 1:1:n
    % Receive stock price relatives
    if (t >= 2)
        [b_t_hat, phi_t_hat] ...
            = RPRT(data(1:t-1, :), phi_tminus1_hat, daily_port_total);
		phi_tminus1_hat = phi_t_hat;
    end
    
    % Normalize
    b_t_hat = b_t_hat./sum(b_t_hat);
    daily_port_total(t, :) = b_t_hat';

    % Cal t's daily return and total return
    daily_incre_fact(t, 1) = (data(t, :)*b_t_hat)*(1-tran_cost/2*sum(abs(b_t_hat-b_tminus1_hat)));
    
    new_return = cum_wealth(max(t-1,1), 1) * daily_incre_fact(t, 1);
    if max_return < new_return
        max_return = new_return;
    end        
    cur_mdd = (max_return - new_return)/max_return;
    if mdd < cur_mdd
        mdd = cur_mdd;
    end
    
    cum_rt = cum_rt + (daily_incre_fact(t, 1)-1);
    cum_rt_vector(t,1) = daily_incre_fact(t, 1)-1;
    cum_wealth(t, 1) = cum_wealth(max(t-1,1), 1) * daily_incre_fact(t, 1);
    
    % Adjust weight(t, :) for the transaction cost issue
    b_tminus1_hat = b_t_hat.*data(t, :)'/daily_incre_fact(t, 1);
end
%{
if cum_wealth(end)<10000
    fprintf('CW is \t %.2f \n',cum_wealth(end));
else
    fprintf('CW is \t %.2e \n',cum_wealth(end));
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