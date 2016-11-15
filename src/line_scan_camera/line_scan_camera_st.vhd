-- line_scan_camera.vhd

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

entity line_scan_camera_st is
	port (
		clock_clk              : in  std_logic                     := '0';             --     clock.clk
		reset_reset            : in  std_logic                     := '0';             --     reset.reset
		
		adc_convst             : out std_logic;                                        --      pins.adc_convst_pin
		adc_sck                : out std_logic;                                        --          .adc_sck_pin
		adc_sdi                : out std_logic;                                        --          .adc_sdi_pin
		adc_sdo                : in  std_logic                     := '0';             --          .adc_sdo_pin
		camera_si              : out std_logic;                                        --          .camera_si_pin
		camera_clk             : out std_logic;                                        --          .camera_clk_in
		
		data_out_data          : out std_logic_vector(31 downto 0);                     --  data_out.data
		data_out_valid         : out std_logic;                                        --          .valid
		data_out_startofpacket : out std_logic;                                        --          .startofpacket
		data_out_endofpacket   : out std_logic;                                        --          .endofpacket

		control_address        : in  std_logic_vector(7 downto 0)  := (others => '0'); --   control.address
		control_read           : in  std_logic                     := '0';             --          .read
		control_readdata       : out std_logic_vector(31 downto 0);                    --          .readdata
		control_write          : in  std_logic                     := '0';             --          .write
		control_writedata      : in  std_logic_vector(31 downto 0) := (others => '0'); --          .writedata
		control_waitrequest    : out std_logic                                         --          .waitrequest
	);
end entity line_scan_camera_st;

architecture rtl of line_scan_camera_st is
	 -- ADC IP
    component LTC2308 port (
        clk : in std_logic;
        reset_n : in std_logic;

        data_capture : in std_logic;
        data_ready : out std_logic;

        data0 : out std_logic_vector(11 downto 0);
        data1 : out std_logic_vector(11 downto 0);
        data2 : out std_logic_vector(11 downto 0);
        data3 : out std_logic_vector(11 downto 0);
        data4 : out std_logic_vector(11 downto 0);
        data5 : out std_logic_vector(11 downto 0);
        data6 : out std_logic_vector(11 downto 0);
        data7 : out std_logic_vector(11 downto 0);

        ADC_CONVST : out std_logic;
        ADC_SCK : out std_logic;
        ADC_SDI : out std_logic;
        ADC_SDO : in std_logic
    );
    end component;

	 -- Camera Signals
    signal camera_in : camera_in_type;
    signal camera_out : camera_out_type;
begin

	-- Instantiate ADC IP
    adc_inst : LTC2308 port map 
    (
        clk => adc_clock_clk,
        reset_n => reset_reset,

        data_capture => camera_out.adc_capture,
        data_ready => camera_in.adc_ready,
        data0 => camera_in.adc_data0,

        ADC_CONVST => adc_convst,
        ADC_SCK => adc_sck,
        ADC_SDI => adc_sdi,
        ADC_SDO => adc_sdo
    );

    -- Camera Reader
    camera_si <= camera_out.camera_si;
    camera_clk <= camera_out.camera_clk;

    camera_inst : camera port map (
        clk => clock_clk,
        rst => reset_reset,

        din => camera_in,
        dout => camera_out
    );

    -- Avalon bus stuff
    data_out_valid <= camera_out.data_valid;
    data_out_startofpacket <= camera_out.data_sof;
    data_out_endofpacket <= camera_out.eof;
    data_out_data <= camera_out.sensor_data;

    -- Ignore for now
	control_readdata <= "00000000000000000000000000000000";
	control_waitrequest <= '0';

end architecture rtl; -- of line_scan_camera
