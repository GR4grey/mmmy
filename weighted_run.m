function [total_ret, day_ret] = weighted_run(data,tc,market,market_vr)
%{
This function is the main function of Trend Representation Based 
Log-density Regularization(TRLR).
Please note that TRLR is protected by patent. Any commercial or industrial
purposes of using TRLR are limited. But it is encouraged for usage of
study and research.

For any usage of this function, the following papers should be cited as reference, 
where parameter settings and details are given in the first paper:

[1] Pei-Yi Yang, Zhao-Rong Lai, Xiaotian Wu, Liangda Fang. ¡°Trend Representation 
Based Log-density Regularization System for Portfolio Optimization¡±,  
Pattern Recognition, vol. 76, pp. 14-24, Apr. 2018.
[2] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. "A Peak Price 
Tracking-Based Learning System for Portfolio Selection", 
IEEE Transactions on Neural Networks and Learning Systems, PP(99):1-10, Jun, 2017.

Inputs:
     data            - market sequence vectors, TxN
     tc              - transaction cost rate

Ouputs:
     total_ret       - total return, Tx1
     day_ret         - daily return, Tx1

%}

W=5;
[T N]=size(data);

% Return Variables
run_ret =1;
cum_rt = 0;
total_ret = ones(T, 1);
day_ret = ones(T, 1);
cum_rt_vector = ones(T,1);
% Portfolio variables, starting with uniform portfolio
day_weight = ones(N, 1)/N;  
day_weight_total=ones(N, T)/N;
day_weight_o = zeros(N, 1);
day_weight_n = zeros(N, 1);
turno = 0;

% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;

%to get the close price according to relative price
data_close = ones(T,N);
for i=2:T
    data_close(i,:)= data_close(i-1,:).*data(i,:);
end

for t = 5:1:T
    
    %Calculate return and total return at the end of the t-th day.
    day_weight_total(:,t)=day_weight;
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    
    new_return = run_ret * day_ret(t, 1);
    if max_return < new_return
        max_return = new_return;
    end       
    cur_mdd = (max_return - new_return)/max_return;
    if mdd < cur_mdd
        mdd = cur_mdd;
    end
    
    cum_rt = cum_rt + (day_ret(t, 1)-1);
    cum_rt_vector(t,1) = day_ret(t, 1)-1;
    run_ret = run_ret * day_ret(t, 1);
    total_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/(data(t, :)*day_weight);

    %Update portfolio
     if(t<T)
        [day_weight_n]=weighted_dayweight_ridge(data_close,data,t+1,day_weight, W);
        
       turno = turno + 0.5*sum(abs(day_weight_n-day_weight));
       day_weight = day_weight_n;
    
     end
end
%{
if total_ret(end)<10000
    fprintf('cw is\t %.2f \n',total_ret(end));
else
    fprintf('cw is\t %.2e \n',total_ret(end));
end
%}
avg_rt = cum_rt/size(data,1);%po daily averge return 
%fprintf('MER is \t%.5f\n',avg_rt-market);
corv = cov(cum_rt_vector,market_vr);%corvaricance matrix
beta = corv(1,2)/(std(market_vr)^2);
alp = avg_rt - beta*market;
se_alp = std(cum_rt_vector)/sqrt(size(data,1));
p_value = alp/se_alp;
%fprintf('alp is \t%.5f\n',alp);
%fprintf('SR is \t%.5f\n',avg_rt/std(cum_rt_vector));
%fprintf('IR is \t%.5f\n',(avg_rt-market)/std(cum_rt_vector-market_vr));
%fprintf('MDD is \t%.5f\n',mdd);
%fprintf('CR is \t%.5f\n',run_ret^(252/T)-1);
%fprintf('\n');
%fprintf('p value is \t%.5f\n',p_value);
end

