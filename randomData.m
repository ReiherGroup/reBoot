% |----------------------------------------------------------------------------
% |If inputOpt.randomData is activated (true), N random data triples are 
% |generated. The generating model is a polynomial of degree M, the M + 1 
% |parameters of which are drawn from a normal distribution. The target values 
% |are drawn from the generating model with normally distributed noise.
% |To date, we only implemented random data generation for dimInput = 1.
% |----------------------------------------------------------------------------

x = sort(unifrnd(-1,1,N,1));
w = normrnd(0,rand,M+1,1).^3;
f = add(x,M) * w;
u = ones(N,1) * (max(f) - min(f)) / (1 + 99 * rand);
d = (max(f) - min(f)) / (1 + 99 * rand);
y = f + normrnd(0,u(1)+d,N,1);

dimInput = 1;

clear('w','f','d');
