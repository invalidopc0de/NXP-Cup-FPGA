-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "06/09/2016 23:48:56"
                                                            
-- Vhdl Test Bench template for design  :  FlightComputerModemFPGA
-- 
-- Simulation tool : Active-HDL (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
use ieee.numeric_std.all;    
USE work.nxp_fpga_types.all;                      

ENTITY ov7670_st_tb IS
END ov7670_st_tb;
ARCHITECTURE test OF ov7670_st_tb IS
    -- constants                    
    constant clk_period : time := 20 ns;  -- 50Mhz

    -- signals                                                   
    SIGNAL clk : STD_LOGIC;
    SIGNAL rst : STD_LOGIC;

    signal line0_out_data : std_logic_vector(7 downto 0);
    
    signal ov_sensor_vsync : std_logic := '0';
    signal ov_sensor_href  : std_logic := '0';
    signal ov_sensor_pclk  : std_logic := '0';
    signal ov_sensor_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal ov_sensor_sioc  : std_logic := '0';
    signal ov_sensor_siod  : std_logic := '0';

    signal control_address     : std_logic_vector(7 downto 0)  := (others => '0'); --   control.address
	signal control_read        : std_logic                     := '0';             --          .read
	signal control_readdata    : std_logic_vector(31 downto 0);                    --          .readdata
	signal control_write       : std_logic                     := '0';             --          .write
	signal control_writedata   : std_logic_vector(31 downto 0) := (others => '0'); --          .writedata
	signal control_waitrequest : std_logic  ;

    signal init_finished : std_logic := '0';

    component ov7670_st is
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
    end component ov7670_st;
BEGIN
    uut: entity work.ov7670_st
        port map (
            clock_clk => clk, 
            reset_reset => rst,

            ov_sensor_vsync => ov_sensor_vsync,
            ov_sensor_href => ov_sensor_href,
            ov_sensor_pclk => ov_sensor_pclk,
            ov_sensor_data => ov_sensor_data,

            ov_sensor_sioc => ov_sensor_sioc,
            ov_sensor_siod => ov_sensor_siod,
            
            control_address     => control_address    ,
            control_read        => control_read       ,
            control_readdata    => control_readdata   ,
            control_write       => control_write      ,
            control_writedata   => control_writedata  ,
            control_waitrequest => control_waitrequest
            );
    
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;

    pclk_process : process
    begin 
        ov_sensor_pclk <= '0';
        wait for clk_period;
        ov_sensor_pclk <= '1';
        wait for clk_period;
    end process;

           
    init : process                                               
    -- variable declarations                                     
    begin                                                        
        -- code that executes only once       

        rst <= '1';
        wait for clk_period*5;
        rst <= '0';

        wait for clk_period*2;     

        control_write <= '1';
        control_writedata(15 downto 0) <= x"1280";

        wait until control_waitrequest = '0';
        
        wait for clk_period;
        control_write <= '0';

        init_finished <= '1';

        wait;                               
    end process init;       
                                        
    always : process                                              
        -- optional sensitivity list                                  
        -- (        )                                                 
        -- variable declarations                                      
    begin                    
        wait until init_finished = '1';

        -- code executes for every event on sensitivity list  
        wait for clk_period*5;

        -- Offset 90 degrees off of the actual clock
        wait for clk_period/2;

        ov_sensor_vsync <= '1';

        wait for 3*128*clk_period*2;

        ov_sensor_vsync <= '0';

        wait for 17*128*clk_period*2;

        for Y in 1 to 128 loop
            ov_sensor_href <= '1';

            for I in 1 to 128 loop
                ov_sensor_data <= std_logic_vector(to_unsigned(I,8)); 

                wait for clk_period*2; -- Pclk
            end loop;

            ov_sensor_href <= '0';

            wait for 144*clk_period*2;
        end loop;

        wait;                                                        
    end process always;                                             
END test;
