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

ENTITY smoother_tb IS
END smoother_tb;
ARCHITECTURE test OF smoother_tb IS
    -- constants                    
    constant clk_period : time := 25 ns;  -- 40Mhz

    -- signals                                                   
    SIGNAL clk				: STD_LOGIC;
    SIGNAL rst				: STD_LOGIC;
	
    signal s_raw_data		: std_logic_vector(31 downto 0);
    signal s_raw_channel	: std_logic_vector( 1 downto 0);
    signal s_raw_valid		: std_logic;
    signal s_raw_sop		: std_logic;
    signal s_raw_eop		: std_logic;
    
BEGIN
    uut: entity work.smoother
        port map (
	        clk				=> clk,
	        rst				=> rst,
	        raw_data		=> s_raw_data,
	        raw_channel		=> s_raw_channel,
	        raw_valid		=> s_raw_valid,
	        raw_sop			=> s_raw_sop,
	        raw_eop			=> s_raw_eop,
	        smooth_data		=> open,
	        smooth_valid	=> open,
	        smooth_sop		=> open,
	        smooth_eop		=> open
        );
        
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
    	--Reset
        rst <= '1';
        wait for clk_period*5;
        rst <= '0';
        
        wait until dout.adc_capture = '1';
        wait for clk_period*20;
        
        din.adc_data0 <= X"123";
        din.adc_ready <= '1';

        wait;
  end process;                                      
END test;
