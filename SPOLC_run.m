function [ cum_wealth, daily_incre_fact, daily_port_total] = SPOLC_run(data,win_size,gamma,tran_cost)
%{
THIS SOURCE CODE IS SUPPLIED ��AS IS�� WITHOUT WARRANTY OF ANY KIND, AND ITS AUTHOR AND THE JOURNAL OF
MACHINE LEARNING RESEARCH (JMLR) AND JMLR��S PUBLISHERS AND DISTRIBUTORS, DISCLAIM ANY AND ALL WARRANTIES,
INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, AND ANY WARRANTIES OR NON INFRINGEMENT. THE USER
ASSUMES ALL LIABILITY AND RESPONSIBILITY FOR USE OF THIS
SOURCE CODE, AND NEITHER THE AUTHOR NOR JMLR, NOR
JMLR��S PUBLISHERS AND DISTRIBUTORS, WILL BE LIABLE FOR
DAMAGES OF ANY KIND RESULTING FROM ITS USE. Without limiting the generality of the foregoing, neither the author, nor JMLR, nor
JMLR��s publishers and distributors, warrant that the Source Code will be
error-free, will operate without interruption, or will meet the needs of the
user.


This function is the main code for "Loss Control with Rank-one Covariance Estimate for Short-term Portfolio Optimization" [1]. 
It adopts a novel rank-one covariance estimate in the principal
rank-one tangent space at the observation matrix in a novel loss control
scheme, which effectively catches the instantaneous risk structure and avoids extreme losses.

For any usage of this function, the following paper(s) should be cited as
reference:

[1] Zhao-Rong Lai, Liming Tan, Xiaotian Wu and Liangda Fang. "Loss Control with Rank-one Covariance Estimate for Short-term Portfolio Optimization", 
Journal of Machine Learning Research, 21(97):1-37, 2020.
[2] Zhao-Rong Lai, Pei-Yi Yang, Liangda Fang and Xiaotian Wu. "Short-term Sparse 
Portfolio Optimization based on Alternating Direction Method of Multipliers", 
Journal of Machine Learning Research, 19(63):1-28, 2018.
[3] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. ��A peak price tracking 
based learning system for portfolio selection��, 
IEEE Transactions on Neural Networks and Learning Systems, 29(7):2823�C2832, Jul. 2018.
[4] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang.  ��Radial basis functions 
with adaptive input and composite trend representation for portfolio selection��, 
IEEE Transactions on Neural Networks and Learning Systems, 29(12):6214�C6226, Dec. 2018.

At the same time, it is encouraged to cite the following papers with previous related works:

[5] B. Li, D. Sahoo, and S. C. H. Hoi. OLPS: a toolbox for on-line portfolio selection. 
Journal of Machine Learning Research, 17(1):1242-1246, 2016.
[6] B. Li, S. C. H. Hoi, D. Sahoo, and Z. Y. Liu. Moving average reversion strategy for on-line
portfolio selection.Articial Intelligence, 222:104-123, 2015.
[7] D. Huang, J. Zhou, B. Li, S. C. H. Hoi, and S. Zhou. Robust median reversion strategy for
online portfolio selection. IEEE Transactions on Knowledge and Data Engineering, 28
(9):2480-2493, Sep. 2016.
[8] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra, ��Efficient
projections onto the \ell_1-ball for learning in high dimensions,�� in
Proceedings of the International Conference on Machine Learning (ICML), 2008.



Inputs:
data                      -data with price relative sequences
win_size                  -window size
tran_cost                 -transaction cost rate
gamma                     -the mixing parameter that trades off between
return and risk

Outputs:
cum_wealth                -cumulative wealths
daily_incre_fact          -daily increasing factors of SSPO
daily_port_total          -daily selected portfolios of SSPO

Example:
[ cum_wealth, daily_incre_fact, daily_port_total] = SPOLC_run(data,5,0.025,0);
%}

%% Parameter Setting

%% Variables Initialization
[T N]=size(data);
cum_wealth = ones(T, 1);
daily_incre_fact = ones(T, 1);
daily_port = ones(N, 1)/N;  
daily_port_total=ones(N, T)/N;
daily_port_o = zeros(N, 1);
run_ret=1;

%% Main
for t = 1:T
    %Calculate t's daily increasing factor and cumulative wealth
    daily_port_total(:,t)=daily_port;
    daily_incre_fact(t, 1) = (data(t, :)*daily_port)*(1-tran_cost/2*sum(abs(daily_port-daily_port_o)));

    run_ret = run_ret * daily_incre_fact(t, 1);
    cum_wealth(t) = run_ret;
    
    % Adjust portfolio for the transaction cost issue
    daily_port_o = daily_port.*data(t, :)'/(data(t, :)*daily_port);
    
    %Update portfolio
     if(t<T)
       [daily_port_n]=SPOLC_extract(data,win_size,gamma,t);
       daily_port = daily_port_n;
     end
    
end



end