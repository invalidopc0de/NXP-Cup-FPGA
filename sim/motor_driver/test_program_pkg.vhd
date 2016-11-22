library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library master_0;
use master_0.altera_avalon_mm_master_bfm_vhdl_pkg.all;

library slave_0;
use slave_0.altera_avalon_mm_slave_bfm_vhdl_pkg.all;

package test_program_pkg is
   
   -----------------------------------------------------
   -- Constants
   -----------------------------------------------------
   constant NUM_MASTERS                : integer := 1;
   constant NUM_SLAVES                 : integer := 1;
   
   constant ADDR_W                     : integer := 12;

   constant SYMBOL_W                   : integer := 8;
   constant NUM_SYMBOLS                : integer := 4;
   constant DATA_W                     : integer := NUM_SYMBOLS * SYMBOL_W;

   constant BURST_W                    : integer := 4;
   constant MAX_BURST                  : integer := 8;

   constant MASTER_RANGE               : integer := 2 ** ADDR_W;
   constant SLAVE_SPAN                 : integer := 16#1000#;
   
   constant MAX_COMMAND_IDLE           : integer := 5;
   constant MAX_COMMAND_BACKPRESSURE   : integer := 2;
   constant MAX_DATA_IDLE              : integer := 3;
   
   -----------------------------------------------------
   -- Enums
   -----------------------------------------------------
   constant WRITE          : integer := 0;
   constant READ           : integer := 1;
   
   constant NOBURST        : integer := 0;
   constant BURST          : integer := 1;
   
   -----------------------------------------------------
   -- Data Structures
   -----------------------------------------------------
   subtype transaction_t   is integer range WRITE to READ;
   subtype burstmode_t     is integer range NOBURST to BURST;
   subtype burstcount_t    is integer range 1 to MAX_BURST;
   
   type data_t          is array(MAX_BURST - 1 downto 0) of std_logic_vector(DATA_W - 1 downto 0);
   type byteenable_t    is array(MAX_BURST - 1 downto 0) of std_logic_vector(NUM_SYMBOLS - 1 downto 0);
   type data_latency_t  is array(MAX_BURST - 1 downto 0) of integer;
   
   type command_t is record
      trans       : transaction_t;
      burstcount  : burstcount_t;
      addr        : std_logic_vector(ADDR_W - 1 downto 0);
      data        : data_t;
      byteenable  : byteenable_t;
      cmd_delay   : integer;
      data_idles  : data_latency_t;
   end record;
   
   type response_t is record
      burstcount  : burstcount_t;
      data        : data_t;
      latency     : data_latency_t;
   end record;
   
   -- fifo
   type size_t is array (1 downto 0) of integer;
   type switch_t is array (boolean) of integer;
   
   -- set queue size 
   constant queue_size_switch : switch_t := (true => NUM_MASTERS, false => NUM_SLAVES);
   constant QUEUE_SIZE        : integer := queue_size_switch(NUM_MASTERS > NUM_SLAVES);
   
   -- command fifo
   type command_with_ptr_t;
   type command_ptr_base is access command_with_ptr_t;
   type command_ptr is array (QUEUE_SIZE - 1 downto 0) of command_ptr_base;
   type command_with_ptr_t is record
      command  : command_t;
      next_cmd : command_ptr_base;
   end record;
   
   type command_fifo_t is protected
      procedure push_back (cmd : in command_t; id : in integer);
      impure function pop_front (id : integer) return command_t;
   end protected command_fifo_t;
   
   -- response fifo
   type response_with_ptr_t;
   type response_ptr_base is access response_with_ptr_t;
   type response_ptr is array (QUEUE_SIZE - 1 downto 0) of response_ptr_base;
   type response_with_ptr_t is record
      response  : response_t;
      next_cmd : response_ptr_base;
   end record;
   
   type response_fifo_t is protected
      procedure push_back (cmd : in response_t; id : in integer);
      impure function pop_front (id : integer) return response_t;
   end protected response_fifo_t;
   
   -----------------------------------------------------
   -- Functions and Procedures
   -----------------------------------------------------
   function to_integer (op: std_logic_vector) return integer;
   
   impure function generate_random_value (min_value, max_value : integer) return integer;
   
   impure function generate_random_value (min_value, max_value, num_bits : integer) return std_logic_vector;
   
   impure function generate_random_aligned_address (slave_id : integer) return std_logic_vector;
   
   impure function create_command (trans      : transaction_t;
                                   burstmode  : integer;
                                   slave_id   : integer) return command_t;
   
   procedure save_command_to_master_queue (cmd        : in command_t;
                                  master_id  : in integer);
   
   procedure save_command_to_slave_queue (cmd      : in command_t;
                                 slave_id : in integer);
   
   procedure configure_and_push_command_to_master (cmd                  : in command_t;
                                                   master_id            : in integer;
                                                   signal api_base_if   : inout mm_mstr_vhdl_if_base_t);
   
   procedure queue_command (cmd           : in command_t;
                            master_id     : in integer;
                            slave_id      : in integer;
                            signal api_if : inout mm_mstr_vhdl_if_t);
   
   procedure get_read_response_from_master (rsp             : out response_t;
                                            master_id       : in integer;
                                            signal api_if   : inout mm_mstr_vhdl_if_base_t);
                                            
   procedure get_read_response_from_master (rsp             : out response_t;
                                            master_id       : in integer;
                                            signal api_if   : inout mm_mstr_vhdl_if_t);
                                            
   impure function get_expected_read_response (slave_id  : in integer) return response_t;
   
   procedure verify_response (actual_rsp, exp_rsp : in response_t);
   
   procedure get_command_from_slave (cmd                 : out command_t;
                                     slave_id            : in integer;
                                     signal api_base_if  : inout mm_slv_vhdl_if_base_t);
   
   procedure get_expected_command_for_slave (cmd      : out command_t;
                                             trans    : in transaction_t;
                                             slave_id : in integer);
   
   procedure verify_command (actual_cmd, exp_cmd : in command_t);
   
   impure function create_response (burstcount : burstcount_t) return response_t;
   
   procedure configure_and_push_response_to_slave (rsp                  : in response_t;
                                                   slave_id             : in integer;
                                                   signal api_base_if   : inout mm_slv_vhdl_if_base_t);
   
   procedure save_response (rsp : in response_t;
                            slave_id : in integer);
   
end test_program_pkg;

package body test_program_pkg is
   
   type command_fifo_t is protected body
      variable size        : size_t := (others => 0);
      variable ptr         : command_ptr  := (others => null);
      
      procedure push_back (cmd   : in command_t;
                           id    : in integer) is
         variable new_cmd  : command_ptr_base;
         variable push_ptr : command_ptr_base;
      begin
         
         new_cmd           := new command_with_ptr_t;         
         new_cmd.command   := cmd;
         new_cmd.next_cmd  := null;
         
         if (size(id) = 0) then            
            ptr(id)  := new_cmd;
         else
            push_ptr := ptr(id);
            while (push_ptr.next_cmd /= null) loop
               push_ptr := push_ptr.next_cmd;
            end loop;
            
            push_ptr.next_cmd := new_cmd;
         end if;
         
         size(id) := size(id) + 1;
      end procedure push_back;
      
      impure function pop_front (id : integer) return command_t is
         variable cmd         : command_t;
      begin
         
         if (size(id) > 0) then
            cmd      := ptr(id).command;
            ptr(id)  := ptr(id).next_cmd;
            size(id) := size(id) - 1;
         else
            report "Queue is empty";
         end if;
         
            return cmd;
      end function pop_front;
      
   end protected body command_fifo_t;
   
   type response_fifo_t is protected body
      variable size        : size_t := (others => 0);
      variable ptr         : response_ptr  := (others => null);
      
      procedure push_back (cmd   : in response_t;
                           id    : in integer) is
         variable new_cmd  : response_ptr_base;
         variable push_ptr : response_ptr_base;
      begin
         
         new_cmd           := new response_with_ptr_t;         
         new_cmd.response   := cmd;
         new_cmd.next_cmd  := null;
         
         if (size(id) = 0) then            
            ptr(id)  := new_cmd;
         else
            push_ptr := ptr(id);
            while (push_ptr.next_cmd /= null) loop
               push_ptr := push_ptr.next_cmd;
            end loop;
            
            push_ptr.next_cmd := new_cmd;
         end if;
         
         size(id) := size(id) + 1;
      end procedure push_back;
      
      impure function pop_front (id : integer) return response_t is
         variable cmd         : response_t;
      begin
         
         if (size(id) > 0) then
            cmd      := ptr(id).response;
            ptr(id)  := ptr(id).next_cmd;
            size(id) := size(id) - 1;
         else
            report "Queue is empty";
         end if;
         
            return cmd;
      end function pop_front;
      
   end protected body response_fifo_t;
   
   -----------------------------------------------------
   -- Command and Response Queues
   -----------------------------------------------------
   -- master command queue
   shared variable write_command_queue_master   : command_fifo_t;
   shared variable read_command_queue_master    : command_fifo_t;
   
   -- slave command queue
   shared variable write_command_queue_slave    : command_fifo_t;
   shared variable read_command_queue_slave     : command_fifo_t;
   
   -- master response queue
   shared variable read_response_queue_slave    : response_fifo_t;
   
   -----------------------------------------------------
   -- Functions and Procedures
   -----------------------------------------------------
   function to_integer (op: std_logic_vector) return integer is
      variable result : integer := 0;
   begin
      if not (is_x(op)) then
         for i in op'range loop
            if op(i) = '1' then
               result := result + 2**i;
            end if;
         end loop; 
         return result;
      else
         return 0;
      end if;
   end to_integer;
   
   shared variable seed1, seed2  : positive := 1;
   impure function generate_random_value (min_value, max_value : integer) return integer is
      variable random_value : real;
   begin
      
      uniform(seed1, seed2, random_value);
      random_value := random_value * real(max_value - min_value) + real(min_value);
      
      return integer(random_value);
   end function generate_random_value;
   
   -- random generator for std_logic_vector type. requires number of bits
   impure function generate_random_value (min_value, max_value, num_bits : integer) return std_logic_vector is
      variable random_value_int  : integer;
   begin
      
      random_value_int := generate_random_value(min_value, max_value);
      return conv_std_logic_vector(random_value_int, num_bits);
   end function generate_random_value;
   
   impure function generate_random_aligned_address (slave_id : integer) return std_logic_vector is
      variable offset, base_addr, addr : integer;
   begin
   
      offset := to_integer(generate_random_value(0, SLAVE_SPAN - 1, ADDR_W));
      base_addr := slave_id * SLAVE_SPAN;
      addr := base_addr + offset;
   
      return conv_std_logic_vector(addr, ADDR_W);
   end function generate_random_aligned_address;
   
   impure function create_command (trans      : transaction_t;
                                   burstmode  : integer;
                                   slave_id   : integer) return command_t is
   
      variable cmd : command_t;
   begin
      
      if (burstmode = BURST) then
         cmd.burstcount := generate_random_value(1, MAX_BURST);
      else
         cmd.burstcount := 1;
      end if;
      
      cmd.trans      := trans;
      cmd.addr       := generate_random_aligned_address(slave_id);
      cmd.cmd_delay  := generate_random_value(0, MAX_COMMAND_IDLE);
      
      if (trans = WRITE) then
         for i in 0 to cmd.burstcount - 1 loop
            cmd.data(i)       := generate_random_value(0, std_logic_vector(DATA_W-1 downto 0)'HIGH, DATA_W);
            cmd.byteenable(i) := (others => '1');
            cmd.data_idles(i) := generate_random_value(0, MAX_DATA_IDLE);
         end loop;
      else
            cmd.data_idles(0) := generate_random_value(0, MAX_DATA_IDLE);         
      end if;
      
      return cmd;
   end function create_command;
   
   procedure save_command_to_master_queue (cmd        : in command_t;
                                  master_id  : in integer) is
   begin
      
      if (cmd.trans = WRITE) then
         write_command_queue_master.push_back(cmd, master_id);
      else
         read_command_queue_master.push_back(cmd, master_id);
      end if;
      
   end procedure save_command_to_master_queue;
   
   procedure save_command_to_slave_queue (cmd      : in command_t;
                                 slave_id : in integer) is
      variable slave_cmd : command_t := cmd;
   begin

      if (cmd.trans = WRITE) then
         write_command_queue_slave.push_back(slave_cmd, slave_id);
      else
         read_command_queue_slave.push_back(slave_cmd, slave_id);
      end if;
      
   end procedure save_command_to_slave_queue;
   
   procedure configure_and_push_command_to_master (cmd                  : in command_t;
                                                   master_id            : in integer;
                                                   signal api_base_if   : inout mm_mstr_vhdl_if_base_t) is
      use work.test_program_pkg.all;
   begin
      
      set_command_address(to_integer(cmd.addr), master_id, api_base_if);
      set_command_burst_count(cmd.burstcount, master_id, api_base_if);
      set_command_burst_size(cmd.burstcount, master_id, api_base_if);
      set_command_init_latency(cmd.burstcount, master_id, api_base_if);
      
      if (cmd.trans = WRITE) then
         set_command_request(master_0.altera_avalon_mm_master_bfm_vhdl_pkg.REQ_WRITE, master_id, api_base_if);
         for i in 0 to cmd.burstcount - 1 loop
            set_command_data(to_integer(cmd.data(i)), i, master_id, api_base_if);
            set_command_byte_enable(to_integer(cmd.byteenable(i)), i, master_id, api_base_if);
            set_command_idle(cmd.data_idles(i), i, master_id, api_base_if);
         end loop;
      else
         set_command_request(master_0.altera_avalon_mm_master_bfm_vhdl_pkg.REQ_READ, master_id, api_base_if);
         set_command_idle(cmd.data_idles(0), 0, master_id, api_base_if);
      end if;
      
      push_command(master_id, api_base_if);
      
   end procedure configure_and_push_command_to_master;
   
   procedure queue_command (cmd           : in command_t;
                            master_id     : in integer;
                            slave_id      : in integer;
                            signal api_if : inout mm_mstr_vhdl_if_t) is
   
   begin
      
      save_command_to_master_queue(cmd, master_id);
      save_command_to_slave_queue(cmd, slave_id);
      
      if (master_id = 0) then
         configure_and_push_command_to_master(cmd, master_id, api_if(0));
      end if;
      
   end procedure queue_command;
   
   procedure get_read_response_from_master (rsp             : out response_t;
                                            master_id       : in integer;
                                            signal api_if   : inout mm_mstr_vhdl_if_base_t) is
      variable burstcount  : burstcount_t;
      variable data        : integer;
   begin
   
      pop_response(master_id, api_if);
      get_response_burst_size(burstcount, master_id, api_if);
      rsp.burstcount := burstcount;
      
      for i in 0 to burstcount - 1 loop
         get_response_data(data, i, master_id, api_if);
         rsp.data(i) := conv_std_logic_vector(data, DATA_W);
      end loop;
   
   end procedure get_read_response_from_master;
   
   procedure get_read_response_from_master (rsp             : out response_t;
                                            master_id       : in integer;
                                            signal api_if   : inout mm_mstr_vhdl_if_t) is
   begin
      
      if (master_id = 0) then
         get_read_response_from_master(rsp, master_id, api_if(0));
      end if;
      
   end procedure get_read_response_from_master;
   
   
   impure function get_expected_read_response (slave_id  : in integer) return response_t is
      variable rsp : response_t;
   begin
      
      rsp := read_response_queue_slave.pop_front(slave_id);
      
      return rsp;
   end function get_expected_read_response;
   
   procedure verify_response (actual_rsp, exp_rsp : in response_t) is
   begin
      
      assert (actual_rsp.burstcount = exp_rsp.burstcount) report "wrong burstcount";
      for i in 0 to actual_rsp.burstcount - 1 loop
         assert (actual_rsp.data(i) = exp_rsp.data(i)) report "wrong read data";
      end loop;
      
   end procedure verify_response;
   
   procedure get_command_from_slave (cmd                 : out command_t;
                                     slave_id            : in integer;
                                     signal api_base_if  : inout mm_slv_vhdl_if_base_t) is

      
      variable trans       : transaction_t;
      variable burstcount  : burstcount_t;
      variable addr        : integer;
      variable data        : integer;
      variable byteenable  : integer;
   begin
      
      pop_command(slave_id, api_base_if);
      get_command_burst_count(burstcount, slave_id, api_base_if);
      get_command_address(addr, slave_id, api_base_if);
      
      cmd.burstcount := burstcount;
      cmd.addr       := conv_std_logic_vector(addr, ADDR_W);
      
      get_command_request(trans, slave_id, api_base_if);
      if (trans = slave_0.altera_avalon_mm_slave_bfm_vhdl_pkg.REQ_WRITE) then
         cmd.trans := WRITE;
         for i in 0 to burstcount - 1 loop
            get_command_data(data, i, slave_id, api_base_if);
            get_command_byte_enable(byteenable, i, slave_id, api_base_if);

            cmd.data(i)       := conv_std_logic_vector(data, DATA_W);
            cmd.byteenable(i) := conv_std_logic_vector(byteenable, NUM_SYMBOLS);
         end loop;
      else
         cmd.trans := READ;
      end if;
      
   end procedure get_command_from_slave;
   
   procedure get_expected_command_for_slave (cmd      : out command_t;
                                             trans    : in transaction_t;
                                             slave_id : in integer) is
   begin
      
      if (trans = WRITE) then
         cmd := write_command_queue_slave.pop_front(slave_id);
      else
         cmd := read_command_queue_slave.pop_front(slave_id);
      end if;
      
   end procedure get_expected_command_for_slave;
   
   procedure verify_command (actual_cmd, exp_cmd : in command_t) is
   begin
      
      assert (actual_cmd.addr = exp_cmd.addr) report "wrong address";
      assert (actual_cmd.burstcount = exp_cmd.burstcount) report "wrong burstcount";

      if (actual_cmd.trans = WRITE) then
         for i in 0 to actual_cmd.burstcount - 1 loop
            assert (actual_cmd.data(i) = exp_cmd.data(i)) report "wrong write data";
            assert (actual_cmd.byteenable(i) = exp_cmd.byteenable(i)) report "wrong byteenable";
         end loop;
      end if;
      
   end procedure verify_command;
   
   impure function create_response (burstcount : burstcount_t) return response_t is
      variable rsp : response_t;
   begin
      
      rsp.burstcount := burstcount;
      for i in 0 to burstcount - 1 loop
         rsp.data(i)    := generate_random_value(0, std_logic_vector(DATA_W-1 downto 0)'HIGH, DATA_W);
         rsp.latency(i) := generate_random_value(0, MAX_DATA_IDLE);
      end loop;
      
      return rsp;
   end function create_response;
   
   procedure configure_and_push_response_to_slave (rsp                  : in response_t;
                                                   slave_id             : in integer;
                                                   signal api_base_if   : inout mm_slv_vhdl_if_base_t) is
   begin
   
      set_response_request(slave_0.altera_avalon_mm_slave_bfm_vhdl_pkg.REQ_READ, slave_id, api_base_if);
      set_response_burst_size(rsp.burstcount, slave_id, api_base_if);
      
      for i in 0 to rsp.burstcount - 1 loop
         set_response_data(to_integer(rsp.data(i)), i, slave_id, api_base_if);
         set_response_latency(rsp.latency(i), i, slave_id, api_base_if);
      end loop;
      push_response(slave_id, api_base_if);
   
   end procedure configure_and_push_response_to_slave;
   
   procedure save_response (rsp : in response_t;
                            slave_id : in integer) is
   begin
      
      read_response_queue_slave.push_back(rsp, slave_id);
      
   end procedure save_response;
   
end test_program_pkg;