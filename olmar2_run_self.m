function [cum_ret, cumprod_ret, daily_ret, daily_portfolio]   = olmar2_run_self( data ,market,market_vr)
% This program simulates the OLMAR-2 algorithm
%
% function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] ...
%    = olmar2_run(fid, data, epsilon, alpha, tc, opts)
%
% cum_ret: a number representing the final cumulative wealth.
% cumprod_ret: cumulative return until each trading period
% daily_ret: individual returns for each trading period
% daily_portfolio: individual portfolio for each trading period
%
% data: market sequence vectors
% fid: handle for write log file
% epsilon: mean reversion threshold
% alpha: trade off parameter for calculating moving average [0, 1]
% tc: transaction cost rate parameter
% opts: option parameter for behvaioral control
%
% Example: [cum_ret, cumprod_ret, daily_ret, daily_portfolio, exp_ret] ...
%           = olmar2_run(fid, data, epsilon, alpha, tc, opts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi
% Contributors:
% Change log: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tc=0;
alpha=0.5;
epsilon=10;
[n, m] = size(data);

% Return variables
cum_ret = 1;
cum_rt = 0;
cum_rt_vector = ones(n,1);
cumprod_ret = ones(n, 1);
daily_ret = ones(n, 1);

% Portfolio weights, starting with uniform portfolio
day_weight = ones(m, 1)/m;  %#ok<*NASGU>
day_weight_o = zeros(m, 1);  % Last closing price adjusted portfolio
daily_portfolio = zeros(n, m);

% print file head
% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;

data_phi = ones(1, m);

%% Trading

for t = 1:1:n,
    % Step 1: Receive stock price relatives
    if (t >= 2)
        [day_weight, data_phi] ...
            = olmar2_kernel(data(1:t-1, :), data_phi, day_weight, epsilon, alpha);
    end
    
    % Normalize the constraint, always useless
    day_weight = day_weight./sum(day_weight);
    daily_portfolio(t, :) = day_weight';
    
    if or((day_weight < -0.00001+zeros(size(day_weight))), (day_weight'*ones(m, 1)>1.00001))
        fprintf(1, 'mrpa_expert: t=%d, sum(day_weight)=%d, pause', t, day_weight'*ones(m, 1));
        pause;
    end

    % Step 2: Cal t's daily return and total return
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
    cum_rt = cum_rt + (daily_ret(t, 1)-1);
    cumprod_ret(t, 1) = cum_ret;
    
    % fprintf(1, '%d\t%.2f\t%.2f\t%.2f\n', t, day_weight(1), day_weight(2), daily_ret(t, 1));
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/daily_ret(t, 1);
    
    % Debug information
    % Time consuming part, other way?

end

% Debug Information
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
% fprintf('MDD is \t%.5f\n',mdd);
% fprintf('CR is \t%.5f\n',(cum_ret^(252/n)-1)/mdd);
% fprintf('\n');
%fprintf('p value is \t%.5f\n',p_value);

end