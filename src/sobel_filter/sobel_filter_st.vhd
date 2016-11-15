-- sobel_filter_st.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.nxp_fpga_types.all;

entity sobel_filter_st is
	port (
		clock_clk              : in  std_logic                    := '0';             --    clock.clk
		reset_n            	   : in  std_logic                    := '0';             --    reset.reset
		
		data_in_data           : in  std_logic_vector(31 downto 0) := (others => '0'); --  data_in.data
		data_in_valid          : in  std_logic                    := '0';             --         .valid
		data_in_startofpacket  : in  std_logic                    := '0';             --         .startofpacket
		data_in_endofpacket    : in  std_logic                    := '0';             --         .endofpacket
		
		data_out_data          : out std_logic_vector(31 downto 0);                    -- data_out.data
		data_out_valid         : out std_logic;                                       --         .valid
		data_out_endofpacket   : out std_logic;                                       --         .endofpacket
		data_out_startofpacket : out std_logic                                        --         .startofpacket
	);
end entity sobel_filter_st;

architecture rtl of sobel_filter_st is
	 -- Edge Filter Signals 
    signal edge_filter_in : edge_filter_in_type;
    signal edge_filter_out : edge_filter_out_type;
begin

	-- Edge filter 
	edge_filter_in.clk <= clock_clk;
	edge_filter_in.reset <= reset_reset;
	edge_filter_in.data <= data_in_data;
	edge_filter_in.data_sof <= data_in_startofpacket;
	edge_filter_in.data_valid <= data_in_valid;

	data_out_data <= edge_filter_out.filtered_data;
	data_out_valid <= edge_filter_out.data_valid;
	data_out_sof <= edge_filter_out.data_sof;

    edge_filter_inst : edge_filter port map (
        clk => clk,
        rst => rst,

        din => edge_filter_in,
        dout => edge_filter_out
    );

	-- Right now, we don't really use this.  
	-- Assume that a new packet starts with each SOP 
	data_out_endofpacket <= '0';	

end architecture rtl; -- of sobel_filter_st
