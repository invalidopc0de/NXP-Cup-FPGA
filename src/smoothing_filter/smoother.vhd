-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.nxp_fpga_types.all;

-- This module should apply a low-pass filter to the data
-- so that we have something that is easier to work with
-- The low pass filter is implemented because it doesn't 
-- require any division, unlike the averaging filter

entity smoother is
	generic (
		/* Length of data from the camera */
		G_DATA_LENGTH	: integer(0 to 256)
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
end smoother;

architecture magic of smoother is 
	/* Types */
	-- Array of samples from channels 1 and 2
    type SAMPLES is array (0 to G_DATA_LENGTH-1) of std_logic_vector(raw_data'length-1 downto 0);
  	-- FSM definition for the smoother
    type smoother_state is (IDLE, READ_PACKET_1, READ_PACKET_2, SMOOTH);
    -- Coefficient array for gaussian smoothing
    type COEFFS_TYPE is array(G_DATA_LENGTH-1 downto 0) of std_logic_vector(31 downto 0);
	
	/* Constants */

	/* Signals */
	-- State machine signals
	signal s_smoother_fsm		: smoother_state;
	signal s_smoother_nxt_state	: smoother_state;
	--sample signal registers
    signal s_data_reg_1 		: SAMPLES;
    signal s_data_reg_2 		: SAMPLES;

begin
	/* State transition process 
	 * Reset is active low
	 */
	smoother_fsm_transition : process(clk, rst)
	begin
		if (rst = '0') then
			s_smoother_fsm 			<= IDLE;
		elsif rising_edge(clk) then
			s_smoother_fsm	 		<= s_smoother_nxt_state;
		end if;
	end process;
	
	/* Asynchronous Smoother State Machine
	 * IDLE -> READ_PACKET_1
	 * READ_PACKET_1 -> IDLE -> READ_PACKET_2
	 * READ_PACKET_2 -> IDLE -> SMOOTH
	 */
    smoother_fsm : process(all)
    begin
        case (s_smoother_fsm) is 
        	when IDLE => 
        		if (raw_valid = '1') then
        			case (raw_channel) is
	        			when "00" =>
	        				s_smoother_nxt_state <= READ_PACKET_1;
	        			when "01" =>
	        				s_smoother_nxt_state <= READ_PACKET_2;
	        			when "10" =>
	        				s_smoother_nxt_state <= SMOOTH;
	        			when others => null;
    				end case;
        		else
        			s_smoother_nxt_state <= IDLE;
    			end if;
			when READ_PACKET_1 =>
				if ((raw_valid & raw_eop) = '1') then
					s_smoother_nxt_state <= IDLE;
				else
					s_smoother_nxt_state <= READ_PACKET_1;
				end if;
			when READ_PACKET_2 =>
				if ((raw_valid & raw_eop) = '1') then
					s_smoother_nxt_state <= IDLE;
				else
					s_smoother_nxt_state <= READ_PACKET_2;
				end if;
			when SMOOTH =>
				if ((raw_valid & raw_eop) = '1') then
					s_smoother_nxt_state <= IDLE;
				else
					s_smoother_nxt_state <= SMOOTH;
				end if;
        end case;
    end process;
	
	packet_regs : process(clk, rst)
		variable ii : integer;
	begin
		if (rst = '0') then
			s_data_reg_1 	<= (others=>(others=>'0'));
			s_data_reg_2 	<= (others=>(others=>'0'));
			ii				:= 0;
		elsif rising_edge(clk) then
			case (s_smoother_fsm) is
				when READ_PACKET_1 =>
					if (raw_valid = 1) then
						s_data_reg_1(ii) 	<= raw_data;
						ii 					:= ii+1;
					end if;
				when READ_PACKET_2 =>
					if (raw_valid = 1) then
						s_data_reg_2(ii) 	<= raw_data;
						ii 					:= ii+1;
					end if;
				when others =>
					ii := 0;
			end case;
		end if;
	end process;
			
	/* Smooth the signal using an ensemble average
	 * The 3 sets of data received from the camera are summed point-by-point
	 * This algorithm is non-loss, and we can perform an average on the resulting 
	 * 	sum or use the sum as our smoothed data.
	 */
	ea_smooth : process (clk)
		variable ii : integer;
	begin
		if (rst = '0') then
	        smooth_data		<= (others => '0');
	        smooth_valid	<= '0';
	        smooth_sop		<= '0';
	        smooth_eop		<= '0';
			ii				:= 0;
		elsif rising_edge(clk) then
			case (s_smoother_fsm) is
				when SMOOTH =>
					if (raw_valid = 1) then
				        smooth_data		<= raw_data + s_data_reg_1(ii) + s_data_reg_2(ii);
				        smooth_valid	<= '1';
				        smooth_sop		<= raw_sop;
				        smooth_eop		<= raw_eop;
						ii				:= ii+1;
					else
						smooth_valid	<= '0';
					end if;
				when others =>
					ii := 0;
			end case;
		end if;
	end process;
	
end magic;
