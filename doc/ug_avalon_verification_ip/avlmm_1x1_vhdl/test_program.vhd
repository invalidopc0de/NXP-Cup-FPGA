library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.all;
use work.test_program_pkg.all;

library master_0;
library slave_0;

entity test_program is
   port (
      clk      : in std_logic := '0';
      reset    : in std_logic := '0'
   );
   
end entity test_program;

architecture test_program_arch of test_program is
   

begin
   
   -----------------------------------------------------   
   -- Test program
   -----------------------------------------------------
   -- master test thread
   process
      use master_0.altera_avalon_mm_master_bfm_vhdl_pkg.all;
      
      procedure master_send_commands (num_command     : in integer;
                                      trans           : in transaction_t;
                                      burstmode       : in burstmode_t;
                                      signal api_if   : inout mm_mstr_vhdl_if_t) is
         
         variable master_id   : integer := 0;
         variable slave_id    : integer := 0;
         variable cmd         : command_t;
         variable actual_rsp  : response_t;
         variable exp_rsp     : response_t;
      begin
         
         for i in 0 to num_command - 1 loop
            
            cmd := create_command(trans, burstmode, slave_id);
            queue_command(cmd, master_id, slave_id, api_if);
            
            event_response_complete(master_id);
            if (trans = READ) then
               get_read_response_from_master(actual_rsp, master_id, api_if);
               exp_rsp := get_expected_read_response(slave_id);
               verify_response(actual_rsp, exp_rsp);
            else
               -- Flush out response for write command created by master bfm
               if (master_id = 0) then
                  pop_response(master_id, api_if(0));
               end if;
            end if;
            
         end loop;
         
      end procedure master_send_commands;
   
   begin
      
      wait until (reset = '0');
      report "Starting master test program";
   
      report "Master sending out non bursting write commands";
      master_send_commands(10, WRITE, NOBURST, req_if);
      
      report "Master sending out non bursting read commands";
      master_send_commands(10, READ, NOBURST, req_if);
      
      report "Master sending out burst write commands";
      master_send_commands(10, WRITE, BURST, req_if);
      
      report "Master sending out burst read commands";
      master_send_commands(10, READ, BURST, req_if);
      
      wait;
   end process;   
   
   -- slave 0 test program
   process
      use slave_0.altera_avalon_mm_slave_bfm_vhdl_pkg.all;
      
      variable slave_id             : integer := 0;
      variable backpressure_cycles  : integer;
      variable actual_cmd           : command_t;
      variable exp_cmd              : command_t;
      variable rsp                  : response_t;
   begin
      event_command_received(slave_id);
      
      -- set random backpressure cycles for next command
      for i in 0 to MAX_BURST - 1 loop
         backpressure_cycles := generate_random_value(0, MAX_COMMAND_BACKPRESSURE);
         set_interface_wait_time(backpressure_cycles, i, slave_id, req_if(0));
      end loop;
      
      get_command_from_slave(actual_cmd, slave_id, req_if(0));
      get_expected_command_for_slave(exp_cmd, actual_cmd.trans, slave_id);
      verify_command(actual_cmd, exp_cmd);
      
      -- set read response
      if (actual_cmd.trans = READ) then
         rsp := create_response(actual_cmd.burstcount);
         configure_and_push_response_to_slave(rsp, slave_id, req_if(0));
         save_response(rsp, slave_id);
      end if;
      
   end process;

end test_program_arch;