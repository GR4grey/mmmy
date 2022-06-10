function [b_tplus1_hat]=CSF_fun3(data_close,data,tplus1, win_size,opts)
%{
THIS SOURCE CODE IS SUPPLIED “AS IS” WITHOUT WARRANTY OF ANY KIND, AND ITS AUTHOR AND THE JOURNAL OF
MACHINE LEARNING RESEARCH (JMLR) AND JMLR’S PUBLISHERS AND DISTRIBUTORS, DISCLAIM ANY AND ALL WARRANTIES,
INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, AND ANY WARRANTIES OR NON INFRINGEMENT. THE USER
ASSUMES ALL LIABILITY AND RESPONSIBILITY FOR USE OF THIS
SOURCE CODE, AND NEITHER THE AUTHOR NOR JMLR, NOR
JMLR’S PUBLISHERS AND DISTRIBUTORS, WILL BE LIABLE FOR
DAMAGES OF ANY KIND RESULTING FROM ITS USE. Without limiting the generality of the foregoing, neither the author, nor JMLR, nor
JMLR’s publishers and distributors, warrant that the Source Code will be
error-free, will operate without interruption, or will meet the needs of the
user.


This function is the main code for the Short-term Sparse Portfolio Optimization 
based on Alternating Direction Method of Multipliers [1]. It concentrates wealth 
on a small proportion of assets that have good increasing potential according to 
some empirical nancial principles, so as to maximize the cumulative wealth for 
the whole investment.

For any usage of this function, the following paper(s) should be cited as
reference:

[1]Zhao-Rong Lai, Pei-Yi Yang, Liangda Fang and Xiaotian Wu. "Short-term Sparse 
Portfolio Optimization based on Alternating Direction Method of Multipliers", 
Journal of Machine Learning Research, 2018. Accepted.

At the same time, it is encouraged to cite the following papers with previous related works:

[2] B. Li, D. Sahoo, and S. C. H. Hoi. OLPS: a toolbox for on-line portfolio selection. 
Journal of Machine Learning Research, 17(1):1242?1246, 2016.
[3] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra, “Efficient
projections onto the \ell_1-ball for learning in high dimensions,” in
Proceedings of the International Conference on Machine Learning (ICML), 2008.


Inputs:
data_close                -close price sequences
data                      -data with price relative sequences
tplus1                    -t+1
daily_port                -daily portfolios of SSPO
b_t_hat               	  -selected portfolio at time t

Output:
b_tplus1_hat              -portfolios selection at time t+1
prim_res               	  -primal residual
iter                 	  -number of iterations
%}

%% Parameter Setting
if isfield(opts,'eplion')
    eplion = opts.eplion;       
else
    eplion = 0.001;
end
if isfield(opts,'st')
    st = opts.st;
else
    st = 3;
end

%% Main
nstk=size(data,2);
I_vec = zeros(nstk,1);

if tplus1<win_size+2
    x_tplus1=data(tplus1-1,:);
else
   Rbefore=data_close((tplus1-win_size):(tplus1-1),:);
   Rpredict=max(Rbefore);
   x_tplus1 = Rpredict./data_close(tplus1-1,:);
end
x_tplus1=1.1*log(x_tplus1)+1;
x = -x_tplus1;
idx = find(x<=(min(x)+eplion));
Imin_num = size(idx,2);
%构造不超过st个数的最优资产的下标集合ist
if Imin_num<=st%如果最优资产不超过st个，那么就让ist=idx
    ist = idx;
else
    %如果最优资产超过了st个，从ist中随机选择三个来构造新的ist
    r = randperm(Imin_num);
    ist = idx(r(1:3));
    
end
%ist = unique(ist);%去掉相同的元素，这里是为了能够让选择的资产是小于等于st个
Ist_num = length(ist);%计算表现的好的资产的个数
for i = 1:Ist_num%将相应的资产置为1
    I_vec(ist(i))=1;
end
b_tplus1_hat=I_vec./Ist_num;

b_tplus1_hat = simplex_projection_selfnorm2(b_tplus1_hat,1);
end
