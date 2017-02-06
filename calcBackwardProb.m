function [bwd_msg, partial_marg] = calcBackwardProb( obsLik, pi1)
% Compute backward message vector for each time-step
% OUTPUT
%   bwd_msg :=  Kz x T matrix
%                    bwds_msg(kz,T) = 1
%                    bwds_msg(kz,t) = p( Y_{t+1:T} | Z_t )
%   partial_marg := Kz x T matrix
%                    partial_marg(kz,t) = p( Y_{t:T} | Z_t )
% INPUT
%   likelihood:  KzxKsxT matrix
%      where lik( kz, ks, t) gives prob. of emissions observed at time t
%                                   if z(t) assigned to hidden state kz
%                                                 and mix. component ks
%      This may be computed up to a norm. const. unique to the timestep t    
%   T      : length of current sequence
%   pi_z   :  Kz x Kz matrix
%              pi_z(j,k) prob. of transition from z_{t}=j to z_{t+1} = k
%   pi_s   :  Kz x Ks matrix,  pi_s(kz,ks) prob. of state ks gen. by kz


% Allocate storage space
Kz = size(pi1,2);
T  = size(obsLik, 2);

bwd_msg     = ones(Kz,T);
partial_marg = zeros(Kz,T);

% Compute messages backwards in time,   from T-1, T-2, ... 2, 1
for tt = T-1:-1:1
  % Multiply likelihood by incoming message:
  partial_marg(:,tt+1) = obsLik(:,tt+1) .* bwd_msg(:,tt+1);
  
  % Integrate out z_t:
  bwd_msg(:,tt) = pi1 * partial_marg(:,tt+1);
  bwd_msg(:,tt) = bwd_msg(:,tt) / sum(bwd_msg(:,tt));
end

% Compute marginal for first time point
partial_marg(:,1) = obsLik(:,1) .* bwd_msg(:,1);

