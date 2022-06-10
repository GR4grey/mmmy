function [run_ret, total_ret, day_ret, turno] = rmr_run_self( data)
epsilon=5;
tc=0;
W=5;

% robust mean reversion approach (rmr) for Portfolio Selection, run file
% Input
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      varargins       - varable parameters, depending on the strategy
%      opts            - simulation environment options
%
% Ouput
%      run_return      - final return, 1x1
%      total_return    - total return, Tx1
%      day_return      - daily return, Tx1

% Extract the parameters 
%tc = varargins;      % transaction cost fee rate



[T N]=size(data);
%T=172;
% Return Variables
%run_ret = 1;
run_ret =[];
total_ret = ones(T, 1);
day_ret = ones(T, 1);

% Portfolio variables, starting with uniform portfolio
day_weight = ones(N, 1)/N;  
day_weight_o = zeros(N, 1);
day_weight_n = zeros(N, 1);
turno = 0;


%to get the close price according to relative price
data_close = ones(T,N);
for i=2:T
    data_close(i,:)= data_close(i-1,:).*data(i,:);
end



k=1;
run_ret(k)=1;
for t = 1:1:T,
    % Step 1: Receive stock price relatives 

    % Step 2: Cal t's return and total return
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));

    run_ret(k) = run_ret(k) * day_ret(t, 1);
    total_ret(t, 1) = run_ret(k);
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);

    % Step 3: Update portfolio
    %if (t<T && t>=W)
     if(t<T)
       %[day_weight]=rmr_day_weight(data,t+1,day_weight, W, epsilon);
       [day_weight_n]=rmr_day_weight(data_close,data,t+1,day_weight, W, epsilon);
       
       turno = turno + sum(abs(day_weight_n-day_weight));
       day_weight = day_weight_n;
    
    end
    

end



turno = turno/(T-1);


end