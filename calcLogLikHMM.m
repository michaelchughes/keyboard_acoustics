function [logPrObs] = calcLogLikHMM( data, model, theta )

T = data.T;
K = model.HMMmodel.nStates;
logPrObs = zeros( T, K );
switch model.obsModel.type
    case 'Discrete'
        for t = 1:T
            logPrObs(t,:) = log( theta.p ) * data.obsHist(t,:)';
        end
    case 'Gaussian'
        for t = 1:T
            for k = 1:K
                muDiff = ( data.obs(t,:)-theta.Mu(k,:) );
                logPrObs(t,k) = -0.5* muDiff*muDiff';
            end
        end
end