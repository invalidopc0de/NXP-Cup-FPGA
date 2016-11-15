library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package nxp_fpga_types is     
    constant SAMPLE_LEN : integer := 12;
   
    -- Camera Types
    type camera_in_type is record
        adc_ready   : std_logic;
        adc_data0   : std_logic_vector(11 downto 0);
    end record;
    
    type camera_out_type is record
        sensor_data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        data_sof    : std_logic; -- Start of frame
        data_eof    : std_logic; -- End of frame
        data_valid  : std_logic;

        adc_capture : std_logic;
        camera_si   : std_logic;
        camera_clk  : std_logic;
    end record;
    
    component camera
    port (
        clk     : in    std_logic;
        rst     : in    std_logic;
        
        din     : in    camera_in_type;
        dout    : out   camera_out_type);
    end component;

    -- Smoother Types
    type smoother_in_type is record
        sensor_data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        data_sof    : std_logic;
        data_valid  : std_logic;
    end record;
    
    type smoother_out_type is record
        smoothed_data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        data_sof    : std_logic;
        data_valid  : std_logic;
    end record;
    
    component smoother
    port (
        clk     : in    std_logic;
        rst     : in    std_logic;
        
        din     : in    smoother_in_type;
        dout    : out   smoother_out_type);
    end component;

    -- Edge Filter 
     type edge_filter_in_type is record
        data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        data_sof    : std_logic;
        data_valid  : std_logic;
    end record;
    
    type edge_filter_out_type is record
        filtered_data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        data_sof    : std_logic;
        data_valid  : std_logic;
    end record;
    
    component edge_filter
    port (
        clk     : in    std_logic;
        rst     : in    std_logic;
        
        din     : in    edge_filter_in_type;
        dout    : out   edge_filter_out_type);
    end component;


end package;