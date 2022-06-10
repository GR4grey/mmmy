[cum_ret,market, cumprod_ret, daily_ret, daily_portfolio] = ubah_run_self( data);
[ cum_wealth, daily_incre_fact, daily_port_total] = AICTR_run( data,win_size,0,market);
[cum_ret, cumprod_ret, daily_ret, daily_portfolio] = best_run_self( data,market);
[cum_ret, cumprod_ret, daily_ret, daily_portfolio] = corn_run_self(data,market);
[cum_ret, cumprod_ret, daily_ret, daily_portfolio]   = olmar2_run_self( data ,market);
[ cum_wealth, daily_incre_fact, daily_port_total] = PPT_run(data, win_size, 0,market);
[cum_wealth, daily_incre_fact, daily_port_total] = RPRT_run(data,market);
[total_ret, day_ret] = weighted_run(data,0,market);

[ cum_wealth, daily_incre_fact, daily_port_total] = SPO_kp_run( data,opts,market);