----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Controller for the OV760 camera - transferes registers to the 
--              camera over an I2C like bus
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_controller is
    Port ( clk   : in    STD_LOGIC;
			rst   : in std_logic;
			sioc  : out   STD_LOGIC;
			siod  : inout STD_LOGIC;
			--reset : out   STD_LOGIC;
			--pwdn  : out   STD_LOGIC;
			xclk  : out   STD_LOGIC;
			cmd : in std_logic_vector(15 downto 0);
			cmd_write : in std_logic;
			cmd_busy : out std_logic
);
end ov7670_controller;

architecture Behavioral of ov7670_controller is
--	COMPONENT ov7670_registers
--	PORT(
--		clk      : IN std_logic;
--		advance  : IN std_logic;          
--		resend   : in STD_LOGIC;
--		command  : OUT std_logic_vector(15 downto 0);
--		finished : OUT std_logic
--		);
--	END COMPONENT;

	COMPONENT i2c_sender
	PORT(
		clk   : IN std_logic;
		send  : IN std_logic;
		taken : out std_logic;
		done  : out std_logic;
		id    : IN std_logic_vector(7 downto 0);
		reg   : IN std_logic_vector(7 downto 0);
		value : IN std_logic_vector(7 downto 0);    
		siod  : INOUT std_logic;      
		sioc  : OUT std_logic
		);
	END COMPONENT;

	signal sys_clk  : std_logic := '0';	
	signal taken : std_logic := '0';
	signal done : std_logic := '0';

	type control_state is (RESET, IDLE, WRITE_REG, WAIT_WRITE, WAIT_WRITE_FINISHED);

    type control_reg_type is record
		send 		: std_logic;
		command  : std_logic_vector(15 downto 0);
		busy 		: std_logic;

        state       : control_state;
    end record;

    constant init : control_reg_type := 
    (
		send => '0',
		command => (others => '0'),
		busy => '0',

        state => RESET
    );

    signal r, rin : control_reg_type := init;


-- Original register set
--	signal command  : std_logic_vector(15 downto 0);
--   	signal finished : std_logic := '0';


	constant camera_address : std_logic_vector(7 downto 0) := x"42"; -- 42"; -- Device write ID - see top of page 11 of data sheet
begin
	 
-- 	send <= not finished;
-- 	Inst_i2c_sender: i2c_sender PORT MAP(
-- 	   clk   => clk,
-- 	   taken => taken,
-- 	   siod  => siod,
-- 	   sioc  => sioc,
-- 	   send  => send,
-- 	   id    => camera_address,
-- 	   reg   => command(15 downto 8),
-- 	   value => command(7 downto 0)
-- 	);
-- 	
-- 		Inst_ov7670_registers: ov7670_registers PORT MAP(
-- 	   clk      => clk,
-- 	   advance  => taken,
-- 	   command  => command,
-- 	   finished => finished,
-- 	   resend   => '0'
-- 	);

	--reset <= '1'; 						-- Normal mode
	--pwdn  <= '0'; 						-- Power device up
	xclk  <= sys_clk;

	Inst_i2c_sender: i2c_sender PORT MAP(
		clk   => clk,
		siod  => siod,
		sioc  => sioc,
		send  => r.send,
		taken => taken,
		done => done,
		id    => camera_address,
		reg   => r.command(15 downto 8),
		value => r.command(7 downto 0)
	);	

	cmd_busy <= r.busy;

    comb : process(clk, rst, cmd, cmd_write) -- Combinational process
        variable v  : control_reg_type;
    begin
        v := r; -- default assignment 

        case (v.state) is 
            when RESET => 
                v := init;
                v.state := IDLE;
            when IDLE =>
			    if (cmd_write = '1') then 
					v.send := '1';
					v.busy := '1';
					v.command := cmd;
					v.state := WRITE_REG;
				end if;
			when WRITE_REG =>
				if (taken = '1') then 
					v.send := '0';
					v.state := WAIT_WRITE;
				end if;
			when WAIT_WRITE =>
				if (done = '1') then 
					v.send := '0';
					v.busy := '0';
					v.state := WAIT_WRITE_FINISHED;
				end if;
			when WAIT_WRITE_FINISHED =>
				if (cmd_write = '0') then 
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

	-- 25 Mhz clock
	process(clk)
	begin
		if rising_edge(clk) then
			sys_clk <= not sys_clk;
		end if;
	end process;
end Behavioral;

