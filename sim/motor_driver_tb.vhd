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

ENTITY motor_driver_tb IS
END motor_driver_tb;
ARCHITECTURE test OF motor_driver_tb IS
    -- constants                    
    constant clk_period : time := 20 ns;  -- 50Mhz

    -- signals                                                   
    SIGNAL clk : STD_LOGIC;
    SIGNAL rst_n : STD_LOGIC;

    signal avs_s0_address   : std_logic_vector(7 downto 0)  := (others => '0'); -- avs_s0.address
    signal avs_s0_read      : std_logic                     := '0';             --       .read
	signal avs_s0_readdata  : std_logic_vector(31 downto 0);                    --       .readdata
	signal avs_s0_write     : std_logic                     := '0';             --       .write
    signal avs_s0_writedata : std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
	signal avs_s0_waitrequest   : std_logic;                                     --       .waitrequest
	signal motor_pin_a      : std_logic;                                        -- output_pins.pin_a
	signal motor_pin_b      : std_logic;                                         --       .pin_b
BEGIN
    uut: entity work.motor_driver_avalon
       generic map (
			sys_clk         => 50000000,
			pwm_freq        => 10000,
			bits_resolution => 8,
			phases          => 1
		)
		port map (
			clk                => clk,                                             --       clock.clk
			reset_n            => rst_n,            --       reset.reset_n
			avs_s0_address     => avs_s0_address,     --      avs_s0.address
			avs_s0_read        => avs_s0_read,        --            .read
			avs_s0_readdata    => avs_s0_readdata,    --            .readdata
			avs_s0_write       => avs_s0_write,       --            .write
			avs_s0_writedata   => avs_s0_writedata,   --            .writedata
			avs_s0_waitrequest => avs_s0_waitrequest, --            .waitrequest
			motor_pin_a        => motor_pin_a,        -- output_pins.pin_a
			motor_pin_b        => motor_pin_b         --            .pin_b
		);
        
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

        rst_n <= '0';
        wait for clk_period*5;
        rst_n <= '1';
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

        avs_s0_address <= X"04";
        avs_s0_write <= '1';
        avs_s0_writedata <= X"00000080"; -- 50% duty

        wait for clk_period;

        avs_s0_write <= '0';

        wait for 500 us;

        avs_s0_address <= X"04";
        avs_s0_write <= '1';
        avs_s0_writedata <= X"000000BF"; -- ~75% duty

        wait for clk_period;

        avs_s0_address <= X"00";
        avs_s0_write <= '1';
        avs_s0_writedata <= X"00000001"; -- Reverse direction

        wait for clk_period;
        wait;                                                        
    end process always;                                             
END test;
