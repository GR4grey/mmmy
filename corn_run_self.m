function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] = corn_run_self(data,market,market_vr)
% This program simulates the BK strategy on data
%
% function [cum_ret, cumprod_ret, daily_ret, daily_portfolio, exp_ret] ...
%    = corn_run(fid, data, w, c, tc, opts)
%
% cum_ret: a number representing the final cumulative wealth.
% cumprod_ret: cumulative return until each trading period
% daily_ret: individual returns for each trading period
% daily_portfolio: individual portfolio for each trading period
% exp_ret: experts' return
%
% data: market sequence vectors
% fid: handle for write log file
% w: window size
% c: correlation coefficient threshold
% tc: transaction cost rate parameter
% opts: option parameter for behvaioral control
%
% Example: [cum_ret, cumprod_ret, daily_ret, daily_portfolio, exp_ret] ...
%            = corn_run(fid, data, w, c, tc, opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi
% Contributors:
% Change log: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w=5;
c=0.1;
%[T, N]=size(data);
[n, m] = size(data);
tc=0;
% Variables for return, start with uniform weight
% cumprod_ret = 1;
% daily_ret = 1;
% weight = ones(nStocks, 1)/nStocks;

cum_ret = 1;
cum_rt = 0;
cumprod_ret = ones(n, 1);
cum_rt_vector = ones(n,1);

daily_ret = ones(n, 1);
day_weight = ones(m, 1)/m;  %#ok<*NASGU>
day_weight_o = zeros(m, 1);
daily_portfolio = zeros(n, m);

% print file head
% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;

for t = 1:1:n,
    % Calculate t's portfolio
    if (t >=2)
        [day_weight] = corn_kernel(data(1:t-1, :), w, c);
    end
    
    % Normalize the constraint
    day_weight = day_weight./sum(day_weight);
    daily_portfolio(t, :) = day_weight';
    
    % Cal t's return and total return
    daily_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    
    new_return = cum_ret * daily_ret(t, 1);
    if max_return < new_return
        max_return = new_return;
    end       
    cur_mdd = (max_return - new_return)/max_return;
    if mdd < cur_mdd
        mdd = cur_mdd;
    end
    
    cum_ret = cum_ret * daily_ret(t, 1);
    cum_rt_vector(t,1) = daily_ret(t, 1)-1;
    cum_rt = cum_rt + (daily_ret(t,1)-1);
    cumprod_ret(t, 1) = cum_ret;
    
    day_weight_o = day_weight.*data(t, :)'/daily_ret(t, 1);
    
    % Debug information
%t
end

% Debug Information
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
% fprintf('MDD is \t%.5f\n',mdd);
% fprintf('CR is \t%.5f\n',(cum_ret^(252/n)-1)/mdd);
% fprintf('\n');
%fprintf('p value is \t%.5f\n',p_value);
end