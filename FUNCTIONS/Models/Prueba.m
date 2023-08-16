% Catchment area
Ap=100; %[50,20,30];
kc= 2; %[0.2, 0.2, 0.2];
fc=sum(Ap)*(1e6/(1000*3600*24*30));
ETP2=100*ones(348,1);


% Parameters
a=0.7;%rand(50,1);
b=200;
c=0.2;
d=0.77;

State=zeros(1,7);



%model
for j=1:1
    for i=2:348
    
        Sw=State(i-1,2);
        Sg=State(i-1,3);
        [Qsim(i,j),ETR(i,1),State(i,:)] = Thomas_fix(P(i), ETP2(i), a, b(j), c, d, kc, Sw, Sg, Ap);
    end
end
%plots
Qsim=Qsim*fc;

figure(1)
plot(Qsim)
%hold on
%plot(Q)
%hold off
%legend('10','25','50','150');

figure(2)
plot(State(:,4))
% 
% 
% d=P-ETP;
% d(d>0)=0;
% plot(d)



