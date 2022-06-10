
load('sp500.mat')

	
[ cum_wealth, daily_incre_fact, daily_port_total] = SPO_kp_run( data,opts);
	
 plot(1:1:size(data,1),cum_wealth,'color','[1 0 0]');
hold on;


[ cum_wealth, daily_incre_fact, daily_port_total] = AICTR_run( data,win_size,tran_cost);

 plot(1:1:size(data,1),cum_wealth,'color','[0 0.4470 0.7410]');
hold on;
[ cum_wealth, daily_incre_fact, daily_port_total] = PPT_run(data, win_size, tran_cost);

plot(1:1:size(data,1),cum_wealth,'color','[0 1 0]');
hold on;
[total_ret, day_ret] = weighted_run(data,0);

 plot(1:1:size(data,1),total_ret,'color','[0 0 1]');
hold on;
[cum_wealth, daily_incre_fact, daily_port_total] = RPRT_run(data);
	 
plot(1:1:size(data,1),cum_wealth,'color','[0 1 1]');
hold on;
[cum_ret, cumprod_ret, daily_ret, daily_portfolio]   = olmar2_run_self( data );
plot(1:1:size(data,1),cumprod_ret,'color','[1 0 1]');
hold on;
[cum_ret, cumprod_ret, daily_ret, daily_portfolio] = corn_run_self(data);
plot(1:1:size(data,1),cumprod_ret,'color','[0.6350 0.0780 0.1840]]');
hold on;
[cum_ret, cumprod_ret, daily_ret, daily_portfolio] = best_run_self( data);
plot(1:1:size(data,1),cumprod_ret,'color','[0.3010 0.7450 0.9330]');
hold on;

[cum_ret, cumprod_ret, daily_ret, daily_portfolio] = ubah_run_self( data);
plot(1:1:size(data,1),cumprod_ret,'color','[0.4660 0.6740 0.1880]');
hold on;
legend({'CP-AICTR','AICTR','PPT','TRLR','RPRT','OLMAR','CORN','Beststock','Market'},'Location','northwest');
hold on;
xlabel('Period');
ylabel('Cumulative Wealth');
axis([0 1276 -inf inf ]);