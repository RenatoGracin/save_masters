syms x
fun = @(x) sin(x*10)+2*sin(x+pi)+3.2;
% fplot(fun)
sym_int = integral(fun,0,10);

time = 0:10/2048:10;
x = fun(time);

disc_int = trapz(time,x);

sum(x)-sym_int
% plot(time,x);


close all
init_dir = '../figures/preprocessing/features_calculation_results/';
FigToOpen = cellstr(uigetfile('*findpeaks*.fig','Select the Figures to open...', init_dir, 'MultiSelect','on') );
global fig_count
fig_count  = 30; %length(FigToOpen)
fig_start = 0;
for ind = 1 : fig_count
    fig = openfig([init_dir FigToOpen{ind+fig_start}],'new','visible');
    fig.KeyPressFcn = @keyPressFcn;
end

function keyPressFcn(obj, eve)
    global fig_count
    if eve.Character == 'n'
        n = rem(obj.Number,fig_count)+1;
        figure(n);
    end
end