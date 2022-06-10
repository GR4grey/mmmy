[cum_ret,market,market_vr, cumprod_ret, daily_ret, daily_portfolio] = ubah_run_self( data);
x = [];
val = [];
for y = 0:0.05:0.5
    opts.tran_cost = y/100;
    [ cum_wealth, daily_incre_fact, daily_port_total] = SPO_kp_run( data,opts,market,market_vr);
    x = [x y];
    val = [val cum_wealth(end)];
end
plot(x,val,'Marker','s','Color','r','Marker','s');
hold on;
x = [];
val = [];
for y = 0:0.05:0.5
    tran_cost = y/100;
    [ cum_wealth, daily_incre_fact, daily_port_total] = AICTR_run( data,win_size,tran_cost,market,market_vr);
    x = [x y];
    val = [val cum_wealth(end)];
end
plot(x,val,'Marker','s','Color','b','Marker','d');
x = [];
val = [];
for y = 0:0.05:0.5
    tran_cost = y/100;
    [ cum_wealth, daily_incre_fact, daily_port_total] = PPT_run(data, win_size, tran_cost,market,market_vr);
    x = [x y];
    val = [val cum_wealth(end)];
end
plot(x,val,'Marker','s','Color','g','Marker','^');
x = [];
val = [];
for y = 0:0.05:0.5
    tc = y/100;
    [total_ret, day_ret] = weighted_run(data,tc,market,market_vr);
    x = [x y];
    val = [val total_ret(end)];
end
plot(x,val,'Marker','s','Color','c','Marker','v');
x = [];
val = [];
for y = 0:0.05:0.5
    tran_cost = y/100;
    [cum_wealth, daily_incre_fact, daily_port_total] = RPRT_run(data,market,market_vr,tran_cost);
    cum_wealth(end);
    x = [x y];
    val = [val cum_wealth(end)];
end
plot(x,val,'Marker','s','Color','m','Marker','*');
legend({'CP-AICTR','AICTR','PPT','TRLR','RPRT'},'Location','northeast');
xlabel('Transaction Cost Rate \gamma(%)');
ylabel('Cumulative Wealth');
