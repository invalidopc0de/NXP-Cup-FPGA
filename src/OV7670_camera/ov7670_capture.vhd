----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Captures the pixels coming from the OV7670 camera and 
--              Stores them in block RAM
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_capture is
    Port ( 
           clk   : in   std_logic;
           rst : in   std_logic;

           pclk  : in   std_logic;
           vsync : in   std_logic;
           href  : in   std_logic;
           din   : in   std_logic_vector (7 downto 0);

           dout     : out  std_logic_vector(7 downto 0);
           valid    : out  std_logic;
           channel  : out std_logic_vector(1 downto 0);
           sop      : out  std_logic;
           eop      : out  std_logic
    );
end ov7670_capture;

architecture Behavioral of ov7670_capture is
    type camera_state is (RESET, WAIT_FOR_VSYNC, WAIT_FOR_HREF, WAIT_FOR_ROW_END, READ_ROW);

    type camera_reg_type is record
        camera_data : std_logic_vector(7 downto 0);
        data_valid  : std_logic;
        channel     : std_logic_vector(1 downto 0);
        sop         : std_logic;
        eop         : std_logic;

        last_pclk   : std_logic;

        channel_index : unsigned(1 downto 0);
        row_index   : unsigned(9 downto 0);
        last_byte_useful : std_logic;

        state       : camera_state;
    end record;

    constant init : camera_reg_type := 
    (
        camera_data => (others => '0'),
        data_valid => '0',
        channel => (others => '0'),
        sop => '0',
        eop => '0',

        last_pclk => '0',
      
        channel_index => (others => '0'),
        row_index => (others => '0'),
        last_byte_useful => '0',

        state => RESET
    );

    signal r, rin : camera_reg_type := init;
begin
    -- Assign outputs
    dout <= r.camera_data;
    valid <= r.data_valid;
    channel <= r.channel;
    sop <= r.sop;
    eop <= r.eop; 


    comb : process(clk, rst, r, pclk, vsync, href, din) -- Combinational process
        variable v  : camera_reg_type;
    begin
        v := r; -- default assignment 

        case (v.state) is 
            when RESET => 
                v := init;
                v.state := WAIT_FOR_VSYNC;
            when WAIT_FOR_VSYNC =>
                v.data_valid := '0';
                v.eop := '0';
                if (vsync = '1') then 
                    v.data_valid := '0';
                    v.state := WAIT_FOR_HREF;
                    v.last_pclk := pclk;
                    v.channel_index := (others => '0');
                    v.row_index := (others => '0');
                end if;
            when WAIT_FOR_HREF =>
                v.data_valid := '0';
                v.eop := '0';
                if ((r.last_pclk = '0' and pclk = '1') and href = '1' ) then
                    -- We are starting a new line
                    if (r.row_index = 60) then -- TODO Update with real value
                        -- Beginning of our line!
                        v.camera_data := din;
                        v.channel := std_logic_vector(r.channel_index);
                        
                        v.last_byte_useful := '0';
                        v.data_valid := '1';

                        v.sop := '1';
                        v.state := READ_ROW;
                    else 
                        v.state := WAIT_FOR_ROW_END;
                    end if;

                    v.row_index := r.row_index + 1;          
                end if;
                 v.last_pclk := pclk;
            when WAIT_FOR_ROW_END =>
                -- This state is used for 'skipping' a line
                v.data_valid := '0';
                v.sop := '0';
                if ((r.last_pclk = '0' and pclk = '1') and href = '0' ) then
                    v.state := WAIT_FOR_HREF;
                end if;
                v.last_pclk := pclk;
            when READ_ROW =>
                -- This state reads in the data 
                v.sop := '0';
                v.data_valid := '0';

                if (href = '1') then 
                    if (r.last_pclk = '0' and pclk = '1') then
                        -- Only every other byte is useful to us (Reading the Y value)
                        if (r.last_byte_useful = '0') then 
                            v.camera_data := din;
                            v.channel := std_logic_vector(r.channel_index);
                            v.data_valid := '1';
                            v.last_byte_useful := '1';
                        else 
                            v.last_byte_useful := '0';
                        end if;
                    end if;
                else 
                    --if(r.channel_index < 2) then 
                    --    -- Increase channel count
                    --    v.channel_index := r.channel_index + 1;
                    --    v.state := WAIT_FOR_HREF;
                    --else 
                    --    v.state := WAIT_FOR_VSYNC;
                    --end if;

                    v.state := WAIT_FOR_VSYNC;
                    
                    v.camera_data := (others => '0');
                    v.eop := '1';
                    v.data_valid := '1';
                end if;

                v.last_pclk := pclk;
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
end Behavioral;