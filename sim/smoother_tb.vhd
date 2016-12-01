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
USE ieee.numeric_std.all;                                          
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
    
    --components
	component smoother is
		generic (
			/* Length of data from the camera */
			G_DATA_LENGTH	: integer
		);
	    port (
	        clk 			: in std_logic; -- 50 Mhz
	        rst 			: in std_logic; -- Active high
			
			/* Raw data streaming input */
			--!{
	        raw_data		: in std_logic_vector(31 downto 0);
	        raw_channel 	: in std_logic_vector(1 downto 0);
	        raw_valid		: in std_logic;
	        raw_sop			: in std_logic;
	        raw_eop			: in std_logic;
	        --!}
			
			/* Smooth data streaming out */
			--!{
	        smooth_data		: out std_logic_vector(31 downto 0);
	        smooth_valid	: out std_logic;
	        smooth_sop		: out std_logic;
	        smooth_eop		: out std_logic
	        --!}
	    );
	end component;
    
BEGIN
	uut: entity work.smoother
		generic map(
			G_DATA_LENGTH => 128
		)
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

    -- Main test process
    main: process
    	-- Reset procedure for all signals
    	procedure RESET is
    	begin
    		rst 			<= '0';
    		s_raw_data		<= (others=>'0');
    		s_raw_channel	<= (others=>'0');
    		s_raw_valid		<= '0';
    		s_raw_sop		<= '0';
    		s_raw_eop		<= '0';
	        wait for clk_period*5;
	        rst 			<= '1';
	        wait for clk_period;
		end RESET;
		
		--procedure for sending streaming data packets
    	procedure SEND_PKT (channel : in integer) is
    	begin
	        for ii in 1 to 127 loop
	        	--start of packet
	        	if (ii = 1) then
	        		s_raw_sop <= '1';
		    		s_raw_eop <= '0';
	    		--end of packet
		    	elsif (ii = 127) then
	    			s_raw_sop <= '0';
		    		s_raw_eop <= '1';
	    		else
	    			s_raw_sop <= '0';
		    		s_raw_eop <= '0';
	    		end if;
	    		s_raw_valid		<= '1';
	    		s_raw_channel	<= std_logic_vector(to_unsigned(channel, s_raw_data'length));
	    		s_raw_data		<= std_logic_vector(to_unsigned(ii, s_raw_data'length));
		        wait for clk_period;
			end loop;
			--reset signals
			s_raw_valid	<= '0';
			s_raw_sop 	<= '0';
			s_raw_eop 	<= '0';
	        wait for clk_period;
		end SEND_PKT;
		
    begin  
    	--Reset
        RESET;
        --send a packet
        SEND_PKT(0);
        SEND_PKT(1);
        SEND_PKT(2);
        wait;
  end process;                                      
END test;
