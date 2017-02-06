function [pi0, pi1, theta] = initHMM_rand( data, model )
K = model.HMMmodel.nStates;
D = data.nDim;
pi0 = rand(1,K);
pi0 = pi0./sum(pi0);

pi1 = rand(K,K);
pi1 = bsxfun(@rdivide, pi1, sum(pi1,2) );

switch model.obsModel.type
    case 'Discrete'
        theta.p = rand(K,D);
        theta.p = bsxfun(@rdivide, theta.p, sum(theta.p, 2)  );
    case 'Gaussian'
        for k = 1:K
            theta.Mu(k,:) = mvnrnd( zeros(1,D), eye(D) );
        end
        
end