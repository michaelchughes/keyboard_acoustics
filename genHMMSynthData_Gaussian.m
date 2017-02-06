%function [X, theta, pi0, pi1] = genHMMSynthData_Discrete( T, K, D)
T = 1000;
K = 10;
D = 2;

model.obsModel.nDim = D;
model.obsModel.type = 'Gaussian';
model.HMMmodel.nStates = K;

initParams.InitFunc = @initHMM_rand;

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

Mu = zeros(K,D);
M = floor(K/2);
kMus = -M*10:10:M*10; %linspace( -10*M, 10*M, K);
if mod(K,2) == 0
    kMus = kMus( [1:M M+2:end] );
end
for k = 1:K
    Mu(k,1) = -kMus(k);
end

z = zeros(1,T);
X = zeros(T,D);
for t = 1:T
    if t == 1
        z(t) = multinomial_single_draw( pi0 );
    else
        z(t) = multinomial_single_draw( pi1( z(t-1), :)  );
    end
    X(t,:) = mvnrnd( Mu( z(t),:), eye(D) );
end

theta = struct();
theta.Mu = Mu;

data = struct();
data.obs = X;
data.T   = T;
data.nDim = D;


True.pi0 = pi0;
True.pi1 = pi1;
True.theta = theta;