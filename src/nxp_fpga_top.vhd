-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;

use work.nxp_fpga_types.all;

entity nxp_fpga_top is
    port (
        CLK50MHZ : in std_logic;
        rst : in std_logic; -- Active high

        -- Camera SPI Lines
        CAM_ADC_CVST    : out std_logic;
        CAM_ADC_MISO    : in std_logic;
        CAM_ADC_MOSI    : out std_logic;
        CAM_ADC_CLK     : out std_logic;
        CAM_CLK         : out std_logic;
        CAM_SI          : out std_logic
    );
end nxp_fpga_top;

architecture magic of nxp_fpga_top is 

    component clock_manager is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic        -- clk
		);
	end component clock_manager;
    
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

    -- Smoother Signals
    signal smoother_in : smoother_in_type;
    signal smoother_out : smoother_out_type;

    -- Edge Filter Signals 
    signal edge_filter_in : edge_filter_in_type;
    signal edge_filter_out : edge_filter_out_type;

    signal clk : std_logic;
    signal clk40Mhz : std_logic; -- For camera reading
begin 

    clk <= CLK50MHZ;

    -- TODO FIX RESETS

    clock_manager_inst : component clock_manager
		port map (
			refclk   => clk,   --  refclk.clk
			rst      => rst,      --   reset.reset
			outclk_0 => clk40Mhz -- outclk0.clk
		);

    -- Instantiate ADC IP
    adc_inst : LTC2308 port map 
    (
        clk => clk40Mhz,
        reset_n => rst,

        data_capture => camera_out.adc_capture,
        data_ready => camera_in.adc_ready,
        data0 => camera_in.adc_data0,

        ADC_CONVST => CAM_ADC_CVST,
        ADC_SCK => CAM_ADC_CLK,
        ADC_SDI => CAM_ADC_MOSI,
        ADC_SDO => CAM_ADC_MISO
    );

    -- Camera Reader

    CAM_SI <= camera_out.camera_si;
    CAM_CLK <= camera_out.camera_clk;

    camera_inst : camera port map (
        clk => clk40Mhz,
        rst => rst,

        din => camera_in,
        dout => camera_out
    );

    -- Data smoother

--    smoother_inst : smoother port map (
--        clk => clk,
--        rst => rst,
--
--        din => smoother_in,
--        dout => smoother_out
--    );

    -- Edge filter 

--    edge_filter_inst : edge_filter port map (
--        clk => clk,
--        rst => rst,
--
--        din => edge_filter_in,
--        dout => edge_filter_out
--    );

end magic;