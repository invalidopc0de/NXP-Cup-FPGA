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
USE work.nxp_fpga_types.all;                      

ENTITY camera_tb IS
END camera_tb;
ARCHITECTURE test OF camera_tb IS
    -- constants                    
    constant clk_period : time := 25 ns;  -- 40Mhz

    -- signals                                                   
    SIGNAL clk : STD_LOGIC;
    SIGNAL rst : STD_LOGIC;

    signal din  : camera_in_type;
    signal dout : camera_out_type;
BEGIN
    uut: entity work.camera
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

    -- Stimulus process
    stim_proc: process
    begin  
        rst <= '1';
        wait for clk_period*5;
        rst <= '0';

        -- Reset first 
        wait until dout.adc_capture = '1';
        wait for clk_period*20;
        
        din.adc_data0 <= X"123";
        din.adc_ready <= '1';

        wait;
  end process;                                      
END test;
