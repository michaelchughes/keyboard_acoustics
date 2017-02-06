%function [logPrTrace, theta, pi1] = learnHMM_EM( data, model, initParams )
%  http://www.mendeley.com/research/training-secondorder-hidden-markov-models-multiple-observation-sequences-1/#page-1
K = model.HMMmodel.nStates;
D = data.nDim;
T = data.T;
[~, ~, theta] = initParams.InitFunc( data, model );

for iter = 1:40

% -------------------------------------------------- E-step
logObsLik = calcLogLikHMM( data, model, theta );
logNorm = max( logObsLik, [], 2);
obsLik = exp( bsxfun(@minus, logObsLik,  logNorm) );
obsLik = obsLik';

[A, logPrObs, Cfwd] = calcForwardProb_2ndOrder( obsLik, pi0, pi1, pi2, logNorm');
[B]    = calcBackwardProb_2ndOrder( obsLik, pi2 );

logPrTrace(iter) = logPrObs(end);

fprintf('iter %d | logPr %.3e\n', iter, logPrTrace(iter) );

% Compute suff stats R1, R2
%   A,B = K x K x T
% A(j,k,t) = p( z_t-1=j, z_t=k | x_1:t )
% B(j,k,t) = p( x_t+1:T | z_t-1=j, z_t=k

%  See Bishop eq. 13.64
R2 = A .* B;
R1 = zeros(K,T);
for t = 2:T
    R2(:,:,t) =  R2(:,:,t) ./ sum(sum(R2(:,:,t) ) );
    R1(:,t) = sum( R2(:,:,t), 1 );
end


% -------------------------------------------------- M-step  theta
switch model.obsModel.type
    case 'Gaussian'
        for k = 1:K
            theta.Mu(k,:) = sum( bsxfun( @times, data.obs', R1(k,:)  ), 2 ) / sum( R1(k,:) );
        end
    case 'Discrete'
        for k = 1:K
           theta.p(k,:) = sum( bsxfun( @times, data.obsHist, R1(k,:)' ), 1) / sum(R1(k,:));
        end
        theta.p = theta.p+eps;
end

% --------------------------------------------------- M-step pi
%pi0 = R1(:,1)' / sum( R1(:,1) );
%pi1 = sum( R2(:,:,2:end), 3 );
%pi1 = bsxfun( @rdivide, pi1, sum(pi1,2) );

end