%%FOURTH ITERATION MODEL:
% finger crossing rule included

clear all
close all

% parameter values (setting the steady state to 6 and 14)
beta = 1/18;
gamma = 1/3;
b = 2; 
a = 2;
R0 = beta*20/gamma
params = {beta, gamma, b, a};

% Initial conditions
Sinit = 14;
Iinit = 1;
Finit = 5;
IC = [Sinit, Iinit, Finit];

% Time span for the simulation
tspan = [0,12];

% Call ode45 to solve the system of ODEs
[t, Y] = ode45(@(t, y)myODEs(t, y, params), tspan, IC);
s = Y(:,1); %susceptible data
i = Y(:,2); %infected data
f = Y(:,3);

% Plot the results
hold on
plot(t, s, 'b');
plot(t, i, 'r');
plot(t, f, 'g');
ylim([0,50])
xlabel('Time');
ylabel('Population');
legend('Susceptible', 'Infected', 'Fingers Crossed');
title('Dynamics of Suscetible, Infected, Fingers Crossed over time');
hold off


% Define the function representing the system of ODEs
function y = myODEs(t, y, params)

[beta,gamma, b, a]=params{:};

S=y(1); I=y(2); F=y(3);

%Model Equation
    dS = -beta*S*I + gamma*I + a*F - b*S;
    dI = beta*S*I - gamma*I;
    dF = b*S - a*F

    y = [dS; dI; dF];
end
