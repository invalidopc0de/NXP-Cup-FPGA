-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.nxp_fpga_types.all;

-- This module should apply a low-pass filter to the data
-- so that we have something that is easier to work with
-- The low pass filter is implemented because it doesn't 
-- require any division, unlike the averaging filter

entity edge_filter is
    port (
        clk : in std_logic; -- 50 Mhz
        rst : in std_logic; -- Active high

        din     : in    edge_filter_in_type;
        dout    : out   edge_filter_out_type
    );
end edge_filter;

architecture magic of edge_filter is 
    type SAMPLE_WINDOW is array (0 to 2) of std_logic_vector(SAMPLE_LEN-1 downto 0);
  
    type edge_filter_state is (RESET, IDLE, SMOOTHING);

    type edge_filter_reg_type is record
        sensor_data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        window      : SAMPLE_WINDOW;
        smoothing_counter : unsigned(7 downto 0);
        
        filtered_data : std_logic_vector(SAMPLE_LEN-1 downto 0);
        data_sof    : std_logic;
        data_valid  : std_logic;
      
        state       : edge_filter_state;
    end record;

    constant init : edge_filter_reg_type := 
    (
        sensor_data => (others => '0'),
        window  => (others => (others => '0')),
        smoothing_counter => (others => '0'),

        filtered_data => (others => '0'),
        data_sof => '0',
        data_valid => '0',
    
        state => RESET
    );

    constant SMOOTHING_DELAY : unsigned(7 downto 0) := to_unsigned(10, 8);

    type COEFS_TYPE is array(0 to 2) of signed(11 downto 0);
    constant COEFS : COEFS_TYPE := (
        to_signed(-1, 12),
        to_signed(0, 12),
        to_signed(1, 12)
    );

    component sobel is
		port (
            result  : out std_logic_vector(11 downto 0);                    --  result.result
            dataa_0 : in  std_logic_vector(11 downto 0) := (others => '0'); -- dataa_0.dataa_0
            dataa_1 : in  std_logic_vector(11 downto 0) := (others => '0'); -- dataa_1.dataa_1
            dataa_2 : in  std_logic_vector(11 downto 0) := (others => '0'); -- dataa_2.dataa_2
            dataa_3 : in  std_logic_vector(11 downto 0) := (others => '0'); -- dataa_3.dataa_3
            datab_0 : in  std_logic_vector(11 downto 0) := (others => '0'); -- datab_0.datab_0
            datab_1 : in  std_logic_vector(11 downto 0) := (others => '0'); -- datab_1.datab_1
            datab_2 : in  std_logic_vector(11 downto 0) := (others => '0'); -- datab_2.datab_2
            datab_3 : in  std_logic_vector(11 downto 0) := (others => '0'); -- datab_3.datab_3
            clock0  : in  std_logic                     := '0';             --  clock0.clock0
            chainin : in  std_logic_vector(11 downto 0) := (others => '0')  -- chainin.chainin
        );
	end component sobel;

    signal sobel_result : std_logic_vector(11 downto 0);

    signal r, rin : edge_filter_reg_type := init;

begin 

    -- Assign outputs
    dout.filtered_data <= r.filtered_data;
    dout.data_sof <= r.data_sof;
    dout.data_valid <= r.data_valid;

    -- Sobel filter implementation.  Essentially just a 
    -- Multiply-Add component with a systolic delay architecture
    sobel_inst : component sobel
		port map (
			result  => sobel_result,  --  result.result
			dataa_0 => r.window(0), -- dataa_0.dataa_0
			dataa_1 => r.window(1), -- dataa_1.dataa_1
			dataa_2 => r.window(2), -- dataa_2.dataa_2
			dataa_3 => (others => '0'), -- dataa_3.dataa_3
			datab_0 => std_logic_vector(COEFS(0)), -- datab_0.datab_0
			datab_1 => std_logic_vector(COEFS(1)), -- datab_1.datab_1
			datab_2 => std_logic_vector(COEFS(2)), -- datab_2.datab_2
			datab_3 => (others => '0'), -- datab_3.datab_3
			clock0  => clk,  --  clock0.clock0
			chainin => (others => '0')  -- chainin.chainin
		);

    comb : process(clk, rst, r, din, sobel_result) -- Combinational process
        variable v  : edge_filter_reg_type;
    begin
        v := r; -- default assignment 

        case (v.state) is 
            when RESET => 
                v := init;
                v.state := IDLE;
            when IDLE =>
                if (din.data_valid = '1') then 
                    v.window(0) := din.data;
                    
                    -- Shift values, unless it's a start of frame
                    -- Then clear them out, so we start with a clean slate
                    if (din.data_sof = '1') then 
                        v.window(1) := (others => '0');
                        v.window(2) := (others => '0');
                    else
                        v.window(1) := r.window(0);
                        v.window(2) := r.window(1);
                    end if;

                    v.data_sof := '0';
                    v.data_valid := '0';
                    v.smoothing_counter := (others => '0');
                    v.state := SMOOTHING;
                end if;
            when SMOOTHING => 
                if (r.smoothing_counter < SMOOTHING_DELAY) then
                    v.smoothing_counter := r.smoothing_counter + 1;
                else
                    -- We might want to truncate negative values.  For now, lets just 
                    -- flip them around. 
                    v.filtered_data := std_logic_vector(abs(signed(sobel_result)));
                    v.data_sof := '0'; -- TODO Implement sof correctly
                    v.data_valid := '1';
                    v.state := IDLE;
                end if;
            when others => 
                v.state := RESET;
        end case;

        if (rst = '1') then 
            v := init;
        end if;

        rin <= v;
    end process;

    regs : process (clk) -- sequential process
    begin 
        if rising_edge(clk) then 
            r <= rin;
        end if;
    end process;
end magic;