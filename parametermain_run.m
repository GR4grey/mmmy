function []=parametermain_run(data,opts)
for epsilon =1000:100:1800
    fprintf('\t 参数为%d时累计财富 \n',epsilon);
    opts.epsilon=epsilon;
    [ ~, ~, ~] = SPOTest_run( data,opts);
    [ ~, ~, ~] = SPOTestsum_run( data,opts);
    [ ~, ~, ~] = SPOTestprod_run( data,opts);
end
end
