%% FITTING DATA TO MODEL:estimating the paramter beta in cheese model using data
% person can infected as many people as possible
% returned to susceptible population after 3 hours
% loading and fitting real collected data 

clear all
close all

% load the data and save data as mat file
excelFilePath = 'Cheese_Data.xlsx';
[cheese, headers] = xlsread(excelFilePath);
matFilePath = 'Cheese_Data.mat';
save(matFilePath, 'cheese', 'headers');

load('Cheese_Data.mat')
t0=cheese(:, 1);
tdata = t0;
susc=cheese(:, 2);
inf=cheese(:, 3);

%Set parameters, initial conditions, time
beta = 1/15;
R0 = beta*20/(1/3)
params = [beta];

tspan = [tdata(1),tdata(end)];

Sinit = 13;
Iinit = 1;
IC = [Sinit, Iinit];

% make initial guess for parameters and plot initial guess model with data
beta1 = 1/15;
params_IG = [beta1];

[t, Yguess] = ode45(@(t, y)myODEs(t, y, params_IG), tspan, IC);
sguess=Yguess(:, 1);
iguess=Yguess(:, 2);


% plot data with true solution
figure(1)
    plot(t, sguess, 'b');
    hold on
    plot(tdata, susc, 'o');
    ylim([0,20])
    xlabel('Time');
    ylabel('Population');
    legend('Guess', 'Susceptible data');
    title('Dynamics of Susceptible over time');
    hold off

figure(2)
    plot(t, iguess, 'b');
    hold on
    plot(tdata, inf, 'o');
    ylim([0,20])
    xlabel('Time');
    ylabel('Population');
    legend('Guess', 'Infected data');
    title('Dynamics of Infected over time');
    hold off




%%% RUN INVERSE PROBLEM


%%call optimization routine to estimate parameters
[Est_params,J] = fminsearch(@(params)costfun(tdata,susc,inf,params,IC),params_IG);

beta_est = Est_params(1)
params_est=[beta_est];

%---------------------------------------------------------
%Plot Model with optimized parameters
%---------------------------------------------------------

[t,Yest] = ode45(@(t,y)myODEs(t,y,params_est),tspan,IC);
suscest = Yest(:, 1);
infest = Yest(:, 2);


%plot data with "true solution"
figure(3)
    plot(t,suscest,'b');
    hold on
    plot(tdata,susc,'o');
    xlabel('hours')
    ylabel('population')
    legend('estimated susceptible','real susceptible')
    title('Estimated Susc with Data')
figure(4)
    plot(t,infest,'b');
    hold on
    plot(tdata,inf,'o');
    xlabel('hours')
    ylabel('population')
    legend('estimated infected','real infected')
    title('Estimated Inf with Data')



%% Cost and Logistic Functions

function J = costfun(tdata,susc,inf,params,IC)
%compute cost function for inverse problem

beta = params(1);

[t,model] = ode45(@(t,y)myODEs(t,y,params),tdata,IC);
suscnew = model(:, 1);
infnew = model(:, 2);

J = sum(((suscnew-susc).^2) + ((infnew-inf).^2)); %compute cost

end


function y = myODEs(t, y, params)

%[beta,gamma]=params{:};
beta=params(1);
gamma=1/3;

S=y(1); I=y(2);

%Model Equation
    dS = -beta*S*I + gamma*I;
    dI = beta*S*I - gamma*I;

    y = [dS; dI];
end
