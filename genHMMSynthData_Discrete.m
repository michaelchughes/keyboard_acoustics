%function [X, theta, pi0, pi1] = genHMMSynthData_Discrete( T, K, D)
T = 1000;
K = 10;
D = 10;

model.obsModel.nDim = D;
model.obsModel.type = 'Discrete';
model.HMMmodel.nStates = K;

initParams.InitFunc = @initHMM_kmeans;

pi0 = [1 zeros( 1, K-1)];
pi1 = zeros( K,K);
for k = 1:K
    if k < K
    pi1(k,:) = [ zeros(1, k-1) 0.9 0.1 zeros( 1, K-k-1 )];
    else
        pi1(k,:) = [zeros(1,k-1) 0.9];
        pi1(k,1) = 0.1;
    end
end

Px = zeros(K,D);
%Px = [10 10 1 1; 1 1 10 10];
for k = 1:K
    Px(k,:) = ones(1,D);
    Px(k, k ) = 50;
    %if mod(k,2) ==0
    %    Px(k, D ) = 25;
    %else
    %    Px(k, D-1) = 25;
    %end
end
Px = bsxfun( @rdivide, Px, sum(Px,2) );

z = zeros(1,T);
X = zeros(1,T);
for t = 1:T
    if t == 1
        z(t) = multinomial_single_draw( pi0 );
    else
        z(t) = multinomial_single_draw( pi1( z(t-1), :)  );
    end
    X(t) = multinomial_single_draw( Px( z(t),: ) );
end

theta.p = Px;
data.obs = X;
data.T   = T;
data.nDim = D;
data.obsHist = zeros(T,D);
for t = 1:T
    data.obsHist(t, X(t) ) = 1;
end

True.pi0 = pi0;
True.pi1 = pi1;
True.theta = theta;