function [fwd_msg, neglog_c] = forward_message_vec(likelihood, neglog_c, T, pi_z, pi_init)
% Computes forward pass of sum-product algorithm to marginize over
%       hidden state assignments in the given time series object
% OUTPUT
%   fwd_msg = Kz x T matrix
%             fwd_msg(k,t) = gives p( Z_t = k | y_{1:t-1}  )
%   neglog_c = 1 x T vector
%             neglog_c( 1 ) =  log p( y_1 )
%             neglog_c( t ) =  log p( y_{1:t} ) - log p( y_{1:t-1} )
%            NOTE:  sum over t=1:T of neglog_c(t)  = log p( y_{1:T} )

% Allocate storage space
Kz = size(pi_z,2);

fwd_msg  = ones(Kz,T);

% Compute marginal for first time point
fwd_msg(:,1) = likelihood(:,1) .* pi_init';
sum_fwd_msg = sum(fwd_msg(:,1));
fwd_msg(:,1) = fwd_msg(:,1) / sum_fwd_msg;
% Add the constant from normalizing the forward message:
neglog_c(1) = neglog_c(1)+log(sum_fwd_msg);

% Compute messages forward in time
%  pi_zT(b,a) = p( z_t+1 =b | z_t = a )  = Prob. transition a --> b
%  pi_zT(:,a) must sum to one (e.g. cols sum to one)
pi_zT = pi_z';

for tt = 1:T-1
  % Integrate out z_t and multiply by likelihood: 
  fwd_msg(:,tt+1) = (pi_zT * fwd_msg(:,tt)) .* likelihood(:,tt+1);
  sum_fwd_msg = sum(fwd_msg(:,tt+1));
  fwd_msg(:,tt+1) = fwd_msg(:,tt+1) / sum_fwd_msg;
 
  % Add the constant from normalizing the forward message:
  neglog_c(tt+1) = neglog_c(tt+1)+log(sum_fwd_msg);
end

end % main function -------------------------------------------------------

% _----------------------------------------------  DEPRECATED -------------
% % Allocate storage space
% Kz = size(pi_z,2);
% T  = length(blockEnd);
% 
% Ks = 0;
% pi_s = [];
% 
% 
% fwd_msg  = ones(Kz,T);
% neglog_c = zeros(1,T);
% 
% 
% % Compute marginalized likelihoods w.r.t. hidden state s
% %   marg_like is a Kz x T matrix
% marg_like = likelihood;
% block_like = marg_like;
% neglog_c = loglike_normalizer;
% 
% % if Kz == 1 && Ks == 1
% %     marg_like = squeeze( likelihood )';  % transpose to make sure it's 1xT
% % elseif Ks == 1
% %     % if Ks == 1, just get rid of extra dimension in likelihood
% %     marg_like = squeeze( likelihood );
% % elseif Ks > 1
% %     marg_like3D = sum(likelihood .* pi_s(:,:,ones(1,1,blockEnd(end))),2);
% %     marg_like = reshape( marg_like3D, Kz, T );
% % end
% 
% % 
% % % If necessary, combine likelihoods within blocks, avoiding underflow
% % if T < blockEnd(end)
% %   marg_like = log(marg_like+eps);
% % 
% %   block_like = zeros(Kz,T);
% %   block_like(:,1) = sum(marg_like(:,1:blockEnd(1)),2);
% %   % Initialize normalization constant to be that due to the likelihood:
% %   neglog_c(1) = sum(loglike_normalizer(1:blockEnd(1)));
% %   for tt = 2:T
% %     block_like(:,tt) = sum(marg_like(:,blockEnd(tt-1)+1:blockEnd(tt)),2);
% %     neglog_c(tt) = sum(loglike_normalizer(blockEnd(tt-1)+1:blockEnd(tt)));
% %   end
% % 
% %   block_norm = max(block_like,[],1);
% %   block_like = exp(block_like - block_norm(ones(Kz,1),:));
% %   % Add on the normalization constant used after marginalizing the s_t's:
% %   neglog_c = neglog_c + block_norm;
% % else
% %    
% %   block_like = marg_like;
% %   % If there is no blocking, the normalization is simply due to the
% %   % likelihood computation:
% %   neglog_c = squeeze(loglike_normalizer)';
% % end
% 
% % Compute marginal for first time point
% fwd_msg(:,1) = block_like(:,1) .* pi_init';
% sum_fwd_msg = sum(fwd_msg(:,1));
% fwd_msg(:,1) = fwd_msg(:,1) / sum_fwd_msg;
% % Add the constant from normalizing the forward message:
% neglog_c(1) = neglog_c(1)+log(sum_fwd_msg);
% 
% % Compute messages forward in time
% %  pi_zT(b,a) = p( z_t+1 =b | z_t = a )  = Prob. transition a --> b
% %  pi_zT(:,a) must sum to one (e.g. cols sum to one)
% pi_zT = pi_z';
% 
% for tt = 1:T-1
%   % Integrate out z_t and multiply by likelihood: 
%   fwd_msg(:,tt+1) = (pi_zT * fwd_msg(:,tt)) .* block_like(:,tt+1);
%   sum_fwd_msg = sum(fwd_msg(:,tt+1));
%   fwd_msg(:,tt+1) = fwd_msg(:,tt+1) / sum_fwd_msg;
%  
%   % Add the constant from normalizing the forward message:
%   neglog_c(tt+1) = neglog_c(tt+1)+log(sum_fwd_msg);
% end