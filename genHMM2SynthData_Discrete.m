%function [X, theta, pi0, pi1] = genHMMSynthData_Discrete( T, K, D)
T = 1000;
K = 2;
D = 5;

model.obsModel.nDim = D;
model.obsModel.type = 'Discrete';
model.HMMmodel.nStates = K;

initParams.InitFunc = @initHMM_kmeans;

pi0 = [1 0];
pi1 = [0.9 0.1;
       0.1 0.9];
pi2 = zeros(K,K,K);
pi2(1,1,:) = [0.9 0.1];
pi2(1,2,:) = [0.25 0.75];
pi2(2,1,:) = [0.75 0.25];
pi2(2,2,:) = [0.1 0.9];

Px = zeros(K,D);
Px = [0.4 0.4 0.2 eps eps;
      eps  eps   0.2 0.4 0.4];
%Px = [10 10 1 1; 1 1 10 10];
%for k = 1:K
%    Px(k,:) = ones(1,D);
%    Px(k, k ) = 50;
    %if mod(k,2) ==0
    %    Px(k, D ) = 25;
    %else
    %    Px(k, D-1) = 25;
    %end
%end
%Px = bsxfun( @rdivide, Px, sum(Px,2) );

z = zeros(1,T);
X = zeros(1,T);
for t = 1:T
    if t == 1
        z(t) = multinomial_single_draw( pi0 );
    elseif t == 2
        z(t) = multinomial_single_draw( pi1( z(t-1), : ) );
    else
        z(t) = multinomial_single_draw( pi2( z(t-2), z(t-1), :)  );
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