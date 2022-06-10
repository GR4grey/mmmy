function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] = olmar1_run_self(data,market,market_vr)
% This program simulates the OLMAR-1 algorithm
%
% function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] ...
%    = olmar1_run(fid, data, epsilon, W, tc, opts)
%
% cum_ret: a number representing the final cumulative wealth.
% cumprod_ret: cumulative return until each trading period
% daily_ret: individual returns for each trading period
% daily_portfolio: individual portfolio for each trading period
%
% data: market sequence vectors
% fid: handle for write log file
% epsilon: mean reversion threshold
% W: window size for moving average
% tc: transaction cost rate parameter
% opts: option parameter for behvaioral control
%
% Example: [cum_ret, cumprod_ret, daily_ret, daily_portfolio, exp_ret] ...
%           = olmar1_run(fid, data, epsilon, W, tc, opts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi
% Contributors:
% Change log: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epsilon=10;
W=5;
tc=0;

[n, m] = size(data);

% Return variables
cum_ret = 1;
cum_rt = 0;
cumprod_ret = ones(n, 1);
cum_rt_vector = ones(n,1);
daily_ret = ones(n, 1);

% Portfolio weights, starting with uniform portfolio
day_weight = ones(m, 1)/m;  %#ok<*NASGU>
day_weight_o = zeros(m, 1);  % Last closing price adjusted portfolio
daily_portfolio = zeros(n, m);

% print file head

%% Trading
for t = 1:1:n,
    % Step 1: Receive stock price relatives
    if (t >= 3)
        [day_weight] = olmar1_kernel(data(1:t-1, :), day_weight, epsilon, W);
    end

    % Normalize the constraint, always useless
    day_weight = day_weight./sum(day_weight);
    daily_portfolio(t, :) = day_weight';
    
    % Step 2: Cal t's daily return and total return
    daily_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    cum_ret = cum_ret * daily_ret(t, 1);
    cum_rt_vector(t,1) = daily_ret(t, 1)-1;
    cum_rt = cum_rt + (daily_ret(t,1)-1);
    cumprod_ret(t, 1) = cum_ret;

    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/daily_ret(t, 1);
    
    % Debug information


    
end

% Debug Information
% Debug Information
avg_rt = cum_rt/size(data,1);%po daily averge return 
fprintf('MER is \t%.5f\n',avg_rt-market);
corv = cov(cum_rt_vector,market_vr);%corvaricance matrix
beta = corv(1,2)/(std(market_vr)^2);
alp = avg_rt - beta*market;
se_alp = std(market_vr)/sqrt(size(data,1));
p_value = alp/se_alp;
fprintf('alp is \t%.5f\n',alp);
fprintf('p value is \t%.5f\n',p_value);


end