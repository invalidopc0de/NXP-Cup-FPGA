-- new_component.vhd

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

entity ov7670_st is
	port (
		reset_reset             : in    std_logic                     := '0';             --     reset.reset
		clock_clk               : in    std_logic                     := '0';             --   clock_1.clk
		
		line0_out_data          : out   std_logic_vector(7 downto 0);                     -- line0_out.data
		line0_out_valid         : out   std_logic;                                        --          .valid
		line0_out_channel       : out   std_logic_vector(1 downto 0);                     --          .channel
		line0_out_startofpacket : out   std_logic;                                        --          .startofpacket
		line0_out_endofpacket   : out   std_logic;                                        --          .endofpacket
		
		ov_sensor_sioc          : out   std_logic;                                        -- ov_sensor.soic
		ov_sensor_siod          : inout std_logic                     := '0';             --          .soid
		ov_sensor_reset         : out   std_logic;                                        --          .reset
		ov_sensor_pwdn          : out   std_logic;                                        --          .pwdn
		ov_sensor_vsync         : in    std_logic                     := '0';             --          .vsync
		ov_sensor_href          : in    std_logic                     := '0';             --          .href
		ov_sensor_pclk          : in    std_logic                     := '0';             --          .pclk
		ov_sensor_xclk          : out   std_logic;                                        --          .xclk
		ov_sensor_data          : in    std_logic_vector(7 downto 0)  := (others => '0'); --          .data
		
		control_address         : in    std_logic_vector(7 downto 0)  := (others => '0'); --   control.address
		control_read            : in    std_logic                     := '0';             --          .read
		control_readdata        : out   std_logic_vector(31 downto 0);                    --          .readdata
		control_write           : in    std_logic                     := '0';             --          .write
		control_writedata       : in    std_logic_vector(31 downto 0) := (others => '0'); --          .writedata
		control_waitrequest     : out   std_logic                                         --          .waitrequest
	);
end entity ov7670_st;

architecture rtl of ov7670_st is
	
	component ov7670_controller
	port (
		clk   : in    std_logic;    
		resend: in    std_logic;    
		config_finished : out std_logic;
		siod  : inout std_logic;      
		sioc  : out   std_logic;
		reset : out   std_logic;
		pwdn  : out   std_logic;
		xclk  : out   std_logic
		);
	end component;

	component ov7670_capture 
	port (
		clk		: in std_logic;
		rst 	: in std_logic;

		pclk 	: in std_logic;
		vsync	: in std_logic;
		href	: in std_logic;
		din 	: in std_logic_vector(7 downto 0);

		dout 	: out std_logic_vector(7 downto 0);
		valid	: out std_logic;
		channel : out std_logic_vector(1 downto 0);
		sop		: out std_logic;
		eop		: out std_logic
	);
	end component;

begin

	capture: ov7670_capture port map(
		clk   => clock_clk,
		rst   => reset_reset,

		pclk  => ov_sensor_pclk,
		vsync => ov_sensor_vsync,
		href  => ov_sensor_href,
		din   => ov_sensor_data,

		dout  	=> line0_out_data,
		valid 	=> line0_out_valid,
		channel => line0_out_channel,
		sop 	=> line0_out_startofpacket,
		eop 	=> line0_out_endofpacket
	);	

	controller: ov7670_controller port map(
		clk   => clock_clk,
		sioc  => ov_sensor_sioc,
		resend => control_write,
		--config_finished => config_finished,
		siod  => ov_sensor_siod,
		--pwdn  => OV7670_PWDN,
		--reset => OV7670_RESET,
		xclk  => ov_sensor_xclk
	);

	ov_sensor_pwdn <= '0';
	ov_sensor_reset <= '0';

	-- Ignore these for now
	control_readdata <= "00000000000000000000000000000000";

	control_waitrequest <= '0';

end architecture rtl; -- of new_component
