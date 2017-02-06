function [bwd_msg] = calcBackwardProbStable( obsLik, pi1, Cfwd )
% Compute backward message vector for each time-step
% OUTPUT
%   bwd_msg :=  Kz x T matrix
%                    bwds_msg(kz,T) = 1
%    bwds_msg(kz,t) = p( x_{t+1:T} | Z_t ) / p( x_t+1:T | x_1:t)
% INPUT
%   likelihood:  KzxT matrix
%      This may be computed up to a norm. const. unique to the timestep t    
%   T      : length of current sequence
%   pi_z   :  Kz x Kz matrix
%              pi_z(j,k) prob. of transition from z_{t}=j to z_{t+1} = k
%   pi_s   :  Kz x Ks matrix,  pi_s(kz,ks) prob. of state ks gen. by kz


% Allocate storage space
Kz = size(pi1,2);
T  = size(obsLik, 2);

bwd_msg     = ones(Kz,T);
bwd_msg(:,T) = bwd_msg(:,T)/sum(bwd_msg(:,T) );
% Compute messages backwards in time, from T-1, T-2, ... 2, 1
%  see Bishop eq. 13.62
for tt = T-1:-1:1
  bwd_msg(:,tt) = pi1 * ( obsLik(:,tt+1) .* bwd_msg(:,tt+1) );
  %bwd_msg(:,tt) = bwd_msg(:,tt) / Cfwd(tt+1);
  bwd_msg(:,tt) = bwd_msg(:,tt)/sum( bwd_msg(:,tt) );
end

