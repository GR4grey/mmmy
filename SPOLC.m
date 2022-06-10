function [ daily_port,optim ] = SPOLC( X,gamma )
%{
THIS SOURCE CODE IS SUPPLIED ��AS IS�� WITHOUT WARRANTY OF ANY KIND, AND ITS AUTHOR AND THE JOURNAL OF
MACHINE LEARNING RESEARCH (JMLR) AND JMLR��S PUBLISHERS AND DISTRIBUTORS, DISCLAIM ANY AND ALL WARRANTIES,
INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, AND ANY WARRANTIES OR NON INFRINGEMENT. THE USER
ASSUMES ALL LIABILITY AND RESPONSIBILITY FOR USE OF THIS
SOURCE CODE, AND NEITHER THE AUTHOR NOR JMLR, NOR
JMLR��S PUBLISHERS AND DISTRIBUTORS, WILL BE LIABLE FOR
DAMAGES OF ANY KIND RESULTING FROM ITS USE. Without limiting the generality of the foregoing, neither the author, nor JMLR, nor
JMLR��s publishers and distributors, warrant that the Source Code will be
error-free, will operate without interruption, or will meet the needs of the
user.


This function is the main code for "Loss Control with Rank-one Covariance Estimate for Short-term Portfolio Optimization" [1]. 
It adopts a novel rank-one covariance estimate in the principal
rank-one tangent space at the observation matrix in a novel loss control
scheme, which effectively catches the instantaneous risk structure and avoids extreme losses.

For any usage of this function, the following paper(s) should be cited as
reference:

[1] Zhao-Rong Lai, Liming Tan, Xiaotian Wu and Liangda Fang. "Loss Control with Rank-one Covariance Estimate for Short-term Portfolio Optimization", 
Journal of Machine Learning Research, 21(97):1-37, 2020.
[2] Zhao-Rong Lai, Pei-Yi Yang, Liangda Fang and Xiaotian Wu. "Short-term Sparse 
Portfolio Optimization based on Alternating Direction Method of Multipliers", 
Journal of Machine Learning Research, 19(63):1-28, 2018.
[3] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang. ��A peak price tracking 
based learning system for portfolio selection��, 
IEEE Transactions on Neural Networks and Learning Systems, 29(7):2823�C2832, Jul. 2018.
[4] Zhao-Rong Lai, Dao-Qing Dai, Chuan-Xian Ren, and Ke-Kun Huang.  ��Radial basis functions 
with adaptive input and composite trend representation for portfolio selection��, 
IEEE Transactions on Neural Networks and Learning Systems, 29(12):6214�C6226, Dec. 2018.

At the same time, it is encouraged to cite the following papers with previous related works:

[5] B. Li, D. Sahoo, and S. C. H. Hoi. OLPS: a toolbox for on-line portfolio selection. 
Journal of Machine Learning Research, 17(1):1242-1246, 2016.
[6] B. Li, S. C. H. Hoi, D. Sahoo, and Z. Y. Liu. Moving average reversion strategy for on-line
portfolio selection.Articial Intelligence, 222:104-123, 2015.
[7] D. Huang, J. Zhou, B. Li, S. C. H. Hoi, and S. Zhou. Robust median reversion strategy for
online portfolio selection. IEEE Transactions on Knowledge and Data Engineering, 28
(9):2480-2493, Sep. 2016.
[8] J. Duchi, S. Shalev-Shwartz, Y. Singer, and T. Chandra, ��Efficient
projections onto the \ell_1-ball for learning in high dimensions,�� in
Proceedings of the International Conference on Machine Learning (ICML), 2008.



Inputs:
X                         -data with price relative sequences
gamma                     -the mixing parameter that trades off between
return and risk

Outputs:
daily_port                -selected portfolio at time t+1
optim (optional)          -the optimized worst-cased increasing factor in
Eq. 52
%}

%% Variables Initialization
[T,N]=size(X);
one_T=ones(T,1);
one_N=ones(N,1);
zero_N=zeros(N,1);
zero_T=zeros(T,1);
z0=[one_N/N;0];
H=zeros(N+1,N+1);

%% Rank-one Covariance
[ V,Sig, U ] = svdself( X );
Sig1=Sig.^2;
Sig2=Sig1-Sig*V'*(one_T*one_T')*V*Sig/T;
zeta=Sig1(1,1)/sqrt(trace(Sig2)/N/(T-1));
Htmp2=U(:,1)*zeta*U(:,1)';

%% Concatenation and Augmentation
H(1:N,1:N)=Htmp2;
f=[zero_N;-1];
A=[-X,one_T];
LB=[zero_N;-Inf];

%% Quadratic Programming
z=quadprog(2*gamma*H,f,A,zero_T,[one_N',0],1,LB,[],z0);
daily_port=z(1:N);
optim=z(N+1);



end

