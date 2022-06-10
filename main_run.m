function []=main_run(data,opts)
[ ~, ~, ~] = PPT_run(data, 5, 0);
[~, ~] = weighted_run(data,0);
[~, ~, ~] = RPRT_run(data);
[ ~, ~, ~] = SPOTest_run( data,opts);
 [ ~, ~, ~] = AICTR_run( data,5,0);
 [ ~, ~, ~] = AICTP_N_run( data,5,0);
[ ~, ~, ~] = SPO_uinf_run( data,5,0);
[ ~, ~, ~] = SPOTest_kf_run( data,opts);
[ ~, ~, ~] = SPOTest_k_run( data,opts);
end
