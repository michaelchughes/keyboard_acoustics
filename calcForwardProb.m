function [fwd_msg, logPrObs, Cfwd] = calcForwardProb( obsLik, pi0, pi1, logNorm)
% Computes forward pass of sum-product algorithm to marginize over
%       hidden state assignments in the given time series object
% INPUT
%   obsLik  = Kz x T matrix
%              obsLik(k,t) = p( x_t | z_t = k ) 
%                   (up to constant multiplicative factor)
%   pi1      = Kz x Kz matrix
%               pi1(j,k) = p( z_t = k | z_t-1 = j )
% OUTPUT
%   fwd_msg = Kz x T matrix
%             fwd_msg(k,t) = gives p( Z_t = k | y_{1:t-1}  )
%   logPrObs = 1 x T matrix
%             logPrObs(t)  = p( x_{1:t} | pi, theta )
%   Cfwd  = 1 x T vector
%              Cfwd(t) = scale factor
%                p( z_t=k, x_1:t ) = fwd_msg(k,t)*prod( c_1:t )

% Allocate storage space
T  = size( obsLik, 2 );
Kz = size(pi1,2);
fwd_msg  = ones(Kz,T);
Cfwd     = zeros(1,T);

% Compute marginal for first time point
fwd_msg(:,1) = obsLik(:,1) .* pi0';
Cfwd(1) = sum(fwd_msg(:,1));
fwd_msg(:,1) = fwd_msg(:,1) / Cfwd(1);

% Compute messages forward in time
%  pi1_T(b,a) = p( z_t+1 =b | z_t = a )  = Prob. transition a --> b
pi1_T = pi1';

for tt = 1:T-1
  % Integrate out z_t and multiply by likelihood: 
  fwd_msg(:,tt+1) = (pi1_T * fwd_msg(:,tt)) .* obsLik(:,tt+1);
  Cfwd(tt+1) = sum( fwd_msg(:,tt+1) );
  fwd_msg(:,tt+1) = fwd_msg(:,tt+1) / Cfwd(tt+1);
end

% Recall that due to normalization for numerical stability,
%  Sfwd(t) = p( x(1:t) ) / p( x(1:t-1)  )
%    so log Sfwd(t) = log p( x_1:t )  - log p( x_1:t-1  )

logPrObs = log( Cfwd ) + logNorm;
logPrObs = cumsum( logPrObs );
%logPrObs = logPrObs + [0 cumsum( logPrObs(1:end-1)  ) ];

% NOTE
%   fmsg = p( z | x_1:t )
%   to convert to p( x_1:t , z )
%     multiply by p( x_1:t ) = exp( logPrObs(t) )

end % main function -------------------------------------------------------
