library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb is
end entity tb;

architecture tb_arch of tb is
   
   -----------------------------------------------------
   -- Constants
   -----------------------------------------------------
   constant CLOCK_PERIOD         : time := 100 ps; -- Clock period in ps
   constant INITIAL_RESET_CYCLES : integer := 10;  -- Number of cycles to reset when simulation starts

   -----------------------------------------------------
   -- Component declaration
   -----------------------------------------------------
   component avlm_avls_1x1 is
      port (
         clk_clk                 : in std_logic := '0';
         reset_reset_n           : in std_logic := '0'
      );
   end component avlm_avls_1x1;

   component test_program is
      port (
         clk                     : in std_logic := '0';
         reset                   : in std_logic := '0'
      );
   end component test_program;
   
   signal clk                    : std_logic :=  '0';
   signal reset                  : std_logic :=  '1';
   signal reset_inv              : std_logic;
   
begin

   dut : component avlm_avls_1x1
      port map(
         clk_clk => clk,
         reset_reset_n => reset_inv
      );
   
   tp : component test_program
      port map(
         clk => clk,
         reset => reset
      );
   
   -- Clock signal generator
   process begin
      wait for (CLOCK_PERIOD / 2);
      clk <= not clk;
   end process;
   
   -- Initial reset
   process begin
      for i in 1 to INITIAL_RESET_CYCLES loop
         wait until (clk = '1');
      end loop;
      
      reset <= '0';      
      wait;
   end process;
   
   reset_inv <= not reset;
   
end tb_arch;