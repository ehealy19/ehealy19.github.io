%%FIRST ITERATION MODEL
%%one person infected at a time, once you pass it on you go back to s
%%constant function of s=19, i=1

close all

% parameter values
beta = 1/19;
gamma=19*beta;
R0 = beta*20/gamma
params = {beta, gamma};

% Initial conditions
Sinit = 19;
Iinit = 1;
IC = [Sinit, Iinit];

% Time span for the simulation
tspan = [0,12];

% Call ode45 to solve the system of ODEs
[t, Y] = ode45(@(t, y)myODEs(t, y, params), tspan, IC);
s = Y(:,1); %susceptible data
i = Y(:,2); %infected data

% Plot the results
hold on
plot(t, s, 'b');
plot(t, i, 'r');
ylim([0,50])
xlabel('Time');
ylabel('Population');
legend('Susceptible', 'Infected');
title('Dynamics of Susc and Infected over time');
hold off


% Define the function representing the system of ODEs
function y = myODEs(t, y, params)

[beta,gamma]=params{:};

S=y(1); I=y(2);

%Model Equation
    dS = -beta*S*I + gamma*I;
    dI = beta*S*I - gamma*I;

    y = [dS; dI];
end
