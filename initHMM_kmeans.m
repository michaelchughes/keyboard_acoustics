function [pi0, pi1, theta] = initHMM_kmeans( data, model )
K = model.HMMmodel.nStates;
D = model.obsModel.nDim;

T = data.T;

[cids, ctrs] = kmeans( data.obsHist, K, 'EmptyAction', 'singleton', 'Replicates', 10 );
R1 = zeros(K,T);
for t = 1:T
    R1(cids(t),t) = 1;
end
R2 = zeros(K,K,T);
for t = 2:T
    R2( cids(t-1), cids(t), t) = 1;
end

pi0 = R1(:,1)' / sum( R1(:,1) );
pi1 = sum( R2(:,:,2:end), 3 );
pi1 = bsxfun( @rdivide, pi1, sum(pi1,2) );
for k = 1:K
    theta.p(k,:) = sum( bsxfun( @times, data.obsHist, R1(k,:)' ), 1) / sum(R1(k,:));
end
theta.p = theta.p+eps;