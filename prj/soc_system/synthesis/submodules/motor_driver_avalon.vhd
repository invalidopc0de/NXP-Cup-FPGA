-- pwm.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

-- This moodule uses the PWM module from here: https://eewiki.net/pages/viewpage.action?pageId=20939345

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity motor_driver_avalon is
	generic (
		sys_clk         : integer := 50000000;
		pwm_freq        : integer := 100000;
		bits_resolution : integer := 8;
		phases          : integer := 1
	);
	port (
		clk                : in  std_logic                     := '0';             --  clock.clk
		reset_n            : in  std_logic                     := '0';             --  reset.reset_n
		avs_s0_address     : in  std_logic_vector(7 downto 0)  := (others => '0'); -- avs_s0.address
		avs_s0_read        : in  std_logic                     := '0';             --       .read
		avs_s0_readdata    : out std_logic_vector(31 downto 0);                    --       .readdata
		avs_s0_write       : in  std_logic                     := '0';             --       .write
		avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
		avs_s0_waitrequest : out std_logic;                                         --       .waitrequest
		motor_pin_a        : out std_logic;                                         -- output_pins.pin_a
		motor_pin_b        : out std_logic                                         --       .pin_b
	);
end entity motor_driver_avalon;

architecture rtl of motor_driver_avalon is
	-- PWM component
	component pwm is
		generic(
			sys_clk         : integer := 50_000_000; --system clock frequency in Hz
			pwm_freq        : integer := 100_000;    --PWM switching frequency in Hz
			bits_resolution : integer := 8;          --bits of resolution setting the duty cycle
			phases          : integer := 1);         --number of output pwms and phases
		port(
			clk       : in  std_logic;                                    --system clock
			reset_n   : in  std_logic;                                    --asynchronous reset
			ena       : in  std_logic;                                    --latches in new duty cycle
			duty      : in  std_logic_vector(bits_resolution-1 DOWNTO 0); --duty cycle
			pwm_out   : out std_logic_vector(phases-1 DOWNTO 0);          --pwm outputs
			pwm_n_out : out std_logic_vector(phases-1 DOWNTO 0));         --pwm inverse outputs
	end component;

	-- State machine stuff
	type motor_driver_state is (RESET, IDLE, WRITE_DUTY);

    type motor_driver_reg_type is record
		direction 	: std_logic;
		duty_cycle	: std_logic_vector(bits_resolution-1 downto 0);

		duty_cycle0	: std_logic_vector(bits_resolution-1 downto 0);
		duty_cycle1	: std_logic_vector(bits_resolution-1 downto 0);
		
		enable0 	: std_logic;
		enable1 	: std_logic;

		-- Avalon stuff
		readdata    : std_logic_vector(31 downto 0);
		waitrequest : std_logic;

        state       : motor_driver_state;
    end record;

    constant init : motor_driver_reg_type := 
    (
        direction => '0',
		duty_cycle => (others => '0'),

		duty_cycle0 => (others => '0'), 
		duty_cycle1 => (others => '0'), 

		enable0 => '0',
		enable1 => '0',

		readdata => (others => '0'),
		waitrequest => '0',

        state => RESET
    );

	signal r, rin : motor_driver_reg_type := init;
begin

	-- Assign outputs
	avs_s0_readdata <= r.readdata;

	avs_s0_waitrequest <= r.waitrequest;

	-- PWM channel 0 module instatiation
	pwm_chan0_inst : component pwm
		generic map (
			sys_clk => sys_clk,
			pwm_freq => pwm_freq,
			bits_resolution => bits_resolution,
			phases => phases
		)
		port map (
			clk => clk,
			reset_n => reset_n,

			ena => r.enable0,
			duty => r.duty_cycle0,

			pwm_out(0) => motor_pin_a
		);

	-- PWM channel 1 module instatiation
	pwm_chan1_inst : component pwm
		generic map (
			sys_clk => sys_clk,
			pwm_freq => pwm_freq,
			bits_resolution => bits_resolution,
			phases => phases
		)
		port map (
			clk => clk,
			reset_n => reset_n,

			ena => r.enable1,
			duty => r.duty_cycle1,

			pwm_out(0) => motor_pin_b
		);

	-- State machine 
    comb : process(clk, reset_n, r, avs_s0_address, avs_s0_read,
					avs_s0_write, avs_s0_writedata) -- Combinational process
        variable v  : motor_driver_reg_type;
    begin
        v := r; -- default assignment 

        case (v.state) is 
            when RESET => 
                v := init;
                v.state := IDLE;
            when IDLE =>
				v.enable0 := '0';
				v.enable1 := '0';

				if (avs_s0_read = '1') then 
					case (avs_s0_address) is 
						when X"00" => 
							v.readdata(0) := r.direction;
						when X"04" =>
							v.readdata(bits_resolution-1 downto 0) := r.duty_cycle;
						when others =>
							v.readdata := (others => '0');
					end case;
				end if;

				if (avs_s0_write = '1') then 
					case (avs_s0_address) is 
						when X"00" => 
							v.direction := avs_s0_writedata(0);
							-- Rewrite the duty cycles to be correct
							if (avs_s0_writedata(0) = '0') then 
								v.duty_cycle0 := r.duty_cycle;
								v.duty_cycle1 := (others => '0');
							else 
								v.duty_cycle0 := (others => '0');
								v.duty_cycle1 :=  r.duty_cycle;
							end if;
							v.state := WRITE_DUTY;
						when X"04" =>
							if (r.direction = '0') then 
								v.duty_cycle0 := avs_s0_writedata(bits_resolution-1 downto 0);
								v.duty_cycle1 := (others => '0');
							else 
								v.duty_cycle0 := (others => '0');
								v.duty_cycle1 := avs_s0_writedata(bits_resolution-1 downto 0);
							end if;
							v.duty_cycle := avs_s0_writedata(bits_resolution-1 downto 0);
							v.state := WRITE_DUTY;
						when others =>
							-- Do nothing? You wrote to an invalid address
					end case;
				end if;
			when WRITE_DUTY =>
				v.enable0 := '1';
				v.enable1 := '1';
				v.state := IDLE;
            when others => 
                v.state := RESET;
        end case;

        if (reset_n = '0') then -- Altera likes active low
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

end architecture rtl; -- of motor_driver_avalon
