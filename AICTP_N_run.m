function [ cum_wealth, daily_incre_fact, daily_port_total] = AICTP_N_run( data,win_size,tran_cost)
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



[T N]=size(data);
phi_t_hat = ones(1, N);



cum_wealth = ones(T, 1);
daily_incre_fact = ones(T, 1);


daily_port = ones(N, 1)/N;  


daily_port_total=ones(N, T)/N;
daily_port_o = zeros(N, 1);


datahat=ones(T, N,3);
datahat_center=ones(T, N,3)/N;



close_price = ones(T,N);
for i=2:T
    close_price(i,:)= close_price(i-1,:).*data(i,:);
end




run_ret=1;
for t = 1:T

    daily_port_total(:,t)=daily_port;

    daily_incre_fact(t, 1) = (data(t, :)*daily_port)*(1-tran_cost/2*sum(abs(daily_port-daily_port_o)));

    run_ret = run_ret * daily_incre_fact(t, 1);
    cum_wealth(t) = run_ret;
    

    daily_port_o = daily_port.*data(t, :)'/(data(t, :)*daily_port);


     if(t<T)

       [daily_port_n,datahat,datahat_center,phi_tplus1_hat]=AICTR_N(close_price,data,t+1,daily_port,datahat,datahat_center,phi_t_hat, win_size);
       phi_t_hat = phi_tplus1_hat;
       daily_port = daily_port_n;
    
    end
    

end
if cum_wealth(end)<10000
    fprintf('\t%.2f\n',cum_wealth(end));
else
    fprintf('\t%.2e\n',cum_wealth(end));
end
end