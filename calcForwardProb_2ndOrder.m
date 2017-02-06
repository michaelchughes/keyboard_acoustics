function [fwd2, logPrObs, Cfwd] = calcForwardProb_2ndOrder( obsLik, pi0, pi1, pi2, logNorm)
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
K = size(pi1,2);
fwd_msg  = ones(K,T);
Cfwd     = zeros(1,T);

% Compute marginal for first time point
%fwd_msg(:,1) = obsLik(:,1) .* pi0';
%Cfwd(1) = sum(fwd_msg(:,1));
%fwd_msg(:,1) = fwd_msg(:,1) / Cfwd(1);

% Compute messages forward in time
%  pi1_T(b,a) = p( z_t+1 =b | z_t = a )  = Prob. transition a --> b
pi1_T = pi1';
fwd2(:,:,2) = bsxfun(@times, pi1_T, (obsLik(:,1) .* pi0') );
fwd2(:,:,2) = bsxfun(@times, fwd2(:,:,2), obsLik(:,2)' );

Cfwd(2) = sum(sum( fwd2(:,:,2) ) );
fwd2(:,:,2) = fwd2(:,:,2)/Cfwd(2);

%fwd_msg(:,2) = sum( fwd2(:,:,2), 1);
%Cfwd(2) = sum( fwd_msg(:,2) );
%fwd_msg(:,2) = fwd2(:,2) / Cfwd(2);

pi2_T = shiftdim( pi2, 2 );
for tt = 2:T-1
  % Integrate out z_t and multiply by likelihood: 
  for j = 1:K
      fwd2(j,:,tt+1) = pi2_T(:,:,j) * fwd2(:,j,tt);
      %for k = 1:K
      %  fwd2(j,k,tt+1) = sum( pi2(:,j,k).* fwd2(:,j,tt) );
      %end
  end
  fwd2(:,:,tt+1) = bsxfun(@times, fwd2(:,:,tt+1), obsLik(:,tt+1)' );
  
  Cfwd(tt+1) = sum(sum(fwd2(:,:,tt+1) ) );
  fwd2(:,:,tt+1) = fwd2(:,:,tt+1)./Cfwd(tt+1);
  
  % Compute p( z_t = k, x_1:t )
  %fwd_msg(:,tt+1) = sum( fwd2(:,:,tt+1), 1);
  
  %Cfwd(tt+1) = sum( fwd_msg(:,tt+1)  );
  %fwd_msg(:,tt+1) = fwd_msg(:,tt+1) / Cfwd(tt+1);
  %fwd_msg(:,tt+1) = (pi1_T * fwd_msg(:,tt)) .* obsLik(:,tt+1);
  %Cfwd(tt+1) = sum( fwd_msg(:,tt+1) );
  %fwd_msg(:,tt+1) = fwd_msg(:,tt+1) / Cfwd(tt+1);
end

% Recall that due to normalization for numerical stability,
%  Cfwd(t) = p( x(1:t) ) / p( x(1:t-1)  )
%    so log Cfwd(t) = log p( x_1:t )  - log p( x_1:t-1  )

logPrObs = [0 log( Cfwd(2:end) )] + logNorm;
logPrObs = cumsum( logPrObs );

end % main function -------------------------------------------------------
