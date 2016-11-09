-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "06/09/2016 23:48:56"
                                                            
-- Vhdl Test Bench template for design  :  FlightComputerModemFPGA
-- 
-- Simulation tool : Active-HDL (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
use ieee.numeric_std.all;    
USE work.nxp_fpga_types.all;                      

ENTITY edge_filter_tb IS
END edge_filter_tb;
ARCHITECTURE test OF edge_filter_tb IS
    -- constants                    
    constant clk_period : time := 25 ns;  -- 40Mhz

    -- signals                                                   
    SIGNAL clk : STD_LOGIC;
    SIGNAL rst : STD_LOGIC;

    signal din  : edge_filter_in_type;
    signal dout : edge_filter_out_type;
BEGIN
    uut: entity work.edge_filter
        port map (
            clk => clk, 
            rst => rst,
            
            din => din,
            dout => dout);
        
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;

           
    init : process                                               
    -- variable declarations                                     
    begin                                                        
        -- code that executes only once       

        rst <= '1';
        wait for clk_period*5;
        rst <= '0';
        wait;                                                       
    end process init;       
                                        
    always : process                                              
        -- optional sensitivity list                                  
        -- (        )                                                 
        -- variable declarations                                      
    begin                                                         
        -- code executes for every event on sensitivity list  
        wait for clk_period*50;

        -- Offset 90 degrees off of the actual clock
        wait for clk_period/2;

        for I in 1 to 128 loop
            if (I < 40) then 
                din.data <= std_logic_vector(to_unsigned(I+1500,12));     
            else 
                din.data <= std_logic_vector(to_unsigned(I,12));
            end if;
            
            
            if (I = 1) then 
                din.data_sof <= '1';
            else 
                din.data_sof <= '0';
            end if;
            din.data_valid <= '1';

            wait for clk_period;

            din.data_valid <= '0';

            wait for clk_period*50;
        end loop;
        wait;                                                        
    end process always;                                             
END test;
