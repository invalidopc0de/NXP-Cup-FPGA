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
    port (
        clk : in std_logic; -- 50 Mhz
        rst : in std_logic; -- Active high

        din     : in    smoother_in_type;
        dout    : out   smoother_out_type
    );
end smoother;

architecture magic of smoother is 
    type SAMPLES is array (0 to 12) of CAMERA_SAMPLE;
  
    type smoother_state is (RESET, IDLE, SMOOTHING);

    type smoother_reg_type is record
        sensor_data : CAMERA_SAMPLE;
      
        state       : smoother_state;
    end record;

    constant init : smoother_reg_type := 
    (
        sensor_data => (others => '0'),
    
        state => RESET
    );

    type COEFFS_TYPE is array()

    signal r, rin : smoother_reg_type := init;

begin 

    comb : process(clk, rst, r, din) -- Combinational process
        variable v  : camera_reg_type;
    begin
        v := r; -- default assignment 

        case (v.state) is 
            when RESET => 
                v := init;
                v.state := WAITING;
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