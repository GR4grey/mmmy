function [cost] = time_cost(t,data,opts,market,market_vr)
% t is the times of running
tic;
for k = 1:t

    [ cum_wealth, daily_incre_fact, daily_port_total] = SPO_kp_run( data,opts,market,market_vr);

end
toc;

end