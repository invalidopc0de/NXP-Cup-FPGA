-- Copyright Mark Saunders 2016

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.nxp_fpga_types.all;

entity camera is
    port (
        clk : in std_logic; -- 40 Mhz
        rst : in std_logic; -- Active high

        din     : in    camera_in_type;
        dout    : out   camera_out_type
    );
end camera;

architecture magic of camera is 
    -- The camera clock needs to be about 100kHz
    -- with a wait of 7.50ms
   
    -- TODO Needs real value
    constant WAITING_CLOCKS : unsigned(15 downto 0) := to_unsigned(10, 16);
    constant DIVIDER : unsigned(8 downto 0) := to_unsigned(400, 9);

    type camera_state is (RESET, WAITING, FIRE_SI, READ_ADC);

    type camera_reg_type is record
        sensor_data : CAMERA_SAMPLE;
        data_valid  : std_logic;
        camera_clk  : std_logic;
        camera_si   : std_logic;

        wait_counter : unsigned(16 downto 0);
        prefix_counter : unsigned(4 downto 0);
        clock_counter : unsigned(8 downto 0);

        -- Keeps track of what sample we're on
        value_index : unsigned(7 downto 0);
        adc_capture : std_logic;

        state       : camera_state;
    end record;

    constant init : camera_reg_type := 
    (
        sensor_data => (others => (others => '0')),
        data_valid => '0',
        camera_clk => '0',
        camera_si => '0',

        wait_counter => (others => '0'),
        prefix_counter => (others => '0'),
        clock_counter => (others => '0'),

        value_index => (others => '0'),
        adc_capture => '0',

        state => RESET
    );

    signal r, rin : camera_reg_type := init;

begin 

    -- Assign outputs
    dout.sensor_data <= r.sensor_data;
    dout.data_valid <= r.data_valid;

    dout.camera_clk <= r.camera_clk;
    dout.camera_si <= r.camera_si;
    dout.adc_capture <= r.adc_capture;

    -- The input clock should be clocked at twice the 
    -- frequency of the camera clock.  This allows us to
    -- do interesting things in the center of a period.  
    -- The module waits a certain amount of time, then 
    -- it reads from the adc sample a bunch of times

    comb : process(clk, rst, r, din) -- Combinational process
        variable v  : camera_reg_type;
    begin
        v := r; -- default assignment 

        case (v.state) is 
            when RESET => 
                v := init;
                v.state := WAITING;
            when WAITING =>
                v.wait_counter := r.wait_counter + 1;
                
                if (r.wait_counter = WAITING_CLOCKS) then 
                    v.data_valid := '0';
                    v.state := FIRE_SI;
                    v.wait_counter := (others => '0');
                end if;
            when FIRE_SI => 
                v.clock_counter := r.clock_counter + 1;

                if (r.clock_counter = 400) then 
                    v.clock_counter := (others => '0');
                    v.prefix_counter := r.prefix_counter + 1;
                    
                    if (r.prefix_counter < 3) then 
                        v.camera_clk := not r.camera_clk;
                    elsif (r.prefix_counter = 3) then 
                        v.camera_clk := '0';
                        v.camera_si := '1';
                    else
                        v.camera_clk := not r.camera_clk;
                        v.state := READ_ADC;
                        v.value_index := (others => '0');
                    end if;
                end if;

            when READ_ADC =>

                v.clock_counter := r.clock_counter + 1;

                if (r.clock_counter = 400) then
                    v.clock_counter := (others => '0');
                    v.camera_si := '0';
                    v.camera_clk := not r.camera_clk;

                    if (r.camera_clk = '1') then 
                        -- Setup so that on the low cycle of the clock
                        -- the ADC will read the value
                        v.adc_capture := '1';
                    else 
                        v.adc_capture := '0';
                    end if;

                    if (din.adc_ready = '1' and r.value_index <= 127) then
                        v.sensor_data := din.adc_data0;
                        v.data_valid := '1';
                        v.value_index := r.value_index + 1; 

                        if (r.value_index == 0) then
                            v.data_sof := '1';
                        else 
                            v.data_sof := '0';
                        end if;

                    end if;

                    if (r.value_index > 127) then 
  
                        v.state := WAITING;
                    end if;
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