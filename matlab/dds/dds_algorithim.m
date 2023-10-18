%%DDS Algorithim
clc
clear

dds_out =   zeros;
thetas  =   [0,0,0,0] ;
deltas  =   [15,30,45,90] ;
ampls   =   [1,1,1,1] ;
sum = 0 ;

for  i = 1:32
    for index = 1:4
        %adder
        lut_index               =   thetas(index) + deltas(index);
        %multiplier and LUT
        out                     =   ampls(index)  * sind(lut_index);
        %accumlator 
        sum                     =   sum + out   ;
        % fifo feedback 
        thetas(index)           =   lut_index   ;
    end
    dds_out(i)  =   sum ;
    sum =  0;
end
plot (dds_out)
%
%% we need 3 FIFOs
% Initialize an empty FIFO queue as a numeric array
thetas_fifo = [];
deltas_fifo = [];
ampls_fifo  = [];

% drive the fifo inputs

%%
