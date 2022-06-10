function [cum_ret,market,market_vr, cumprod_ret, daily_ret, daily_portfolio] = ubah_run_self( data)
% This file is the run core for the market strategy.
%
% function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] = market_run(fid, data, tc, opts)
%
% cum_ret: cumulative wealth achived at the end of a period.
% cumprod_ret: cumulative wealth achieved till the end each period.
% daily_ret: daily return achieved by a strategy.
% daily_portfolio: daily portfolio, achieved by the strategy
%
% data: market sequence vectors
% fid: handle for write log file
% tc: transaction fee rate
% opts: option parameter for behvaioral control
%
% Example: [cum_ret, cumprod_ret, daily_ret] ...
%          = market_run(fid, data, 0, opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi
% Contributors:
% Change log: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tc=0;
[n, m]=size(data);

% Variables for return, start with uniform weight
cum_ret = 1;
cumprod_ret = ones(n, 1);
daily_ret = ones(n, 1);
cum_rt = 0;
cum_rt_vector = ones(n,1);

% portfolio at the beinning (end) of a period
day_weight = ones(m, 1)/m;  %#ok<*NASGU>
day_weight_o = zeros(m, 1);
daily_portfolio = zeros(n, m);

% print log file head
% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;
% Backtests
for t = 1:1:n,
    
    % Calculate t's portfolio at the beginning of t-th trading day
    if (t >= 6)
        [day_weight] = ubah_kernel(data(1:t-1, :), day_weight_o);
    end
    
    % Normalize the constraint, always useless
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
    
    cum_rt = cum_rt + (daily_ret(t, 1)-1);
    
    cumprod_ret(t, 1) = cum_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/daily_ret(t, 1);
    
    % Log information

end

% Output the cumulative return and log it.
market = cum_rt/size(data,1);%average return 
%fprintf('Market daily return is \t%.5f\n',market);
market_vr = cum_rt_vector; % daily return vector
%fprintf('Market SR is \t%.5f\n',market/std(market_vr));
%fprintf('MDD is \t%.5f\n',mdd);
%fprintf('CR is \t%.5f\n',(cum_ret^(252/n)-1)/mdd);
%fprintf('\n');
end
%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%