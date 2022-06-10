function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] = best_run_self( data,market,market_vr)
% This file simulates the best stock strategy.
%
% function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] ...
%    = best_run(fid, data, tc, opts)
% cum_ret: cumulative wealth achived at the end of a period.
% cumprod_ret: cumulative wealth achieved till the end each period.
% daily_ret: daily return achieved by a strategy.
% daily_portfolio: daily portfolio
%
% data: market sequence vectors
% fid: handle for write log file
% tc: transaction costs rate
% opts: option parameter for behvaioral control
%
% Example: [cum_ret, cumprod_ret, daily_ret, daily_portfolio] ...
%             = best_run(fid, data, tc, opts)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi
% Contributors:
% Change log: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tc=0;
[n, m] = size(data);

% Variables for return, start with uniform weight
cum_ret = 1;
cum_rt = 0;
cum_rt_vector = ones(n,1);

cumprod_ret = ones(n, 1);
daily_ret = ones(n, 1);
ret_m = ones(n, 2);  % cumprod_ret + daily_ret
day_weight = ones(m, 1)/m;  %#ok<*NASGU>
day_weight_o = zeros(m, 1);
daily_portfolio = zeros(n, m);

% print file head


% print log file head
% MDD and CR
max_return = 0; % until t day the max St
mdd = 0;

% Calculate wealth return for each stock
tmp_daily_ret 	= ones(m, 1);
tmp_cumprod_ret 	= ones(m, 1);

for t = 1:n,
	tmp_daily_ret 	= data(t, :)';
	tmp_cumprod_ret 	= tmp_cumprod_ret.*tmp_daily_ret;
end;

% Find the maximum and its index
[~, best_ind] = max(tmp_cumprod_ret);

day_weight = zeros(m, 1); 
day_weight(best_ind)=1;

for t = 1:1:n,
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
    cum_rt = cum_rt + (daily_ret(t,1)-1);
    
    
    cumprod_ret(t, 1) = cum_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/daily_ret(t, 1);
    
    % Debug information
    % Time consuming part, other way?

end
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