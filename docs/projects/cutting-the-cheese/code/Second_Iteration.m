%%SECOND ITERATION MODEL
% an infected person is added every 3 hours, same rules apply
% step function with s decreasing, i increasing

close all

% Initial conditions
Sinit = 19;
Iinit = 1;
IC = [Sinit, Iinit];
N = 20; %total population remains constant 

% parameter values (changing every 3 hours)
beta = Iinit/Sinit;
gamma=19*beta;
R0 = beta*20/gamma
params = {beta, gamma};

beta3 = Iinit/Sinit;
gamma3 = 18*beta3;
R03 = beta3*20/gamma3;
params3 = {beta3, gamma3};

beta6 = Iinit/Sinit;
gamma6 = 17*beta6;
R06 = beta6*20/gamma6;
params6 = {beta6, gamma6};

beta9 = Iinit/Sinit;
gamma9 = 16*beta9;
R09 = beta9*20/gamma9;
params9 = {beta9, gamma9};

% total time to run the simulation
tspan = [0,3];
tspan3 = [3,6];
tspan6 = [6,9];
tspan9 = [9,12];

% Call ode45 to solve the system of ODEs (solving each time frame)
[t3, Y3] = ode45(@(t, y)myODEs(t, y, params), tspan, IC);
s3 = Y3(end,1); %susceptible data
i3 = Y3(end,2); %infected data

[t6, Y6] = ode45(@(t, y)myODEs(t, y, params3), tspan3, [s3-1, i3+1]);
s6 = Y6(end,1); %susceptible data
i6 = Y6(end,2); %infected data

[t9, Y9] = ode45(@(t, y)myODEs(t, y, params6), tspan6, [s6-1, i6+1]);
s9 = Y9(end,1); %susceptible data
i9 = Y9(end,2); %infected data

[t12, Y12] = ode45(@(t, y)myODEs(t, y, params9), tspan9, [s9-1, i9+1]);
s12 = Y12(end,1); %susceptible data
i12 = Y12(end,2); %infected data

ssol = [Y3(:,1);Y6(:,1);Y9(:,1);Y12(:,1)];
isol = [Y3(:,2);Y6(:,2);Y9(:,2);Y12(:,2)];

tsol = [t3;t6;t9;t12];


% Plotting the results of susc and inf
hold on 
plot(tsol, ssol, 'b');
plot(tsol, isol, 'r');
ylim([0,50])
xlabel('Time');
ylabel('Population');
legend('Susceptible', 'Infected');
title('Dynamics of Susc and Infected over time');
hold off


% function representing the system of diff eqs 
function y = myODEs(t, y, params)
[beta,gamma]=params{:};

S=y(1); I=y(2);

% Equation for the model 
    dS = -beta*S*I + gamma*I;
    dI = beta*S*I - gamma*I;

    y = [dS; dI];
end


%% when looking at the R0 value can conclude that this is not the correct
% model to look and also talk about how forcing the parameters
% to change the equilibrium and stay at the new eq in each time frame
