function [bwds_msg, partial_marg] = backwards_message_vec(likelihood, T, pi_z,pi_s)
% Compute backward message vector for each time-step
% OUTPUT
%   bwds_msg :=  Kz x T matrix
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
Kz = size(pi_z,2);
%T  = length(blockEnd);


% Compute marginalized likelihoods by integrating over all mix. comp. states
%   marg_like := Kz x T matrix
marg_like = likelihood;

% If necessary, combine likelihoods within blocks, avoiding underflow
block_like = marg_like;

% if T < blockEnd(end)
%   marg_like = log(marg_like+eps);
% 
%   block_like = zeros(Kz,T);
%   block_like(:,1) = sum(marg_like(:,1:blockEnd(1)),2);
%   for tt = 2:T
%     block_like(:,tt) = sum(marg_like(:,blockEnd(tt-1)+1:blockEnd(tt)),2);
%   end
% 
%   block_norm = max(block_like,[],1);
%   block_like = exp(block_like - block_norm(ones(Kz,1),:));
% else
%   block_like = marg_like;
% end


bwds_msg     = ones(Kz,T);
partial_marg = zeros(Kz,T);

% Compute messages backwards in time,   from T-1, T-2, ... 2, 1
for tt = T-1:-1:1
  % Multiply likelihood by incoming message:
  partial_marg(:,tt+1) = block_like(:,tt+1) .* bwds_msg(:,tt+1);
  
  % Integrate out z_t:
  bwds_msg(:,tt) = pi_z * partial_marg(:,tt+1);
  bwds_msg(:,tt) = bwds_msg(:,tt) / sum(bwds_msg(:,tt));
end

% Compute marginal for first time point
partial_marg(:,1) = block_like(:,1) .* bwds_msg(:,1);

