library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.test_data.all;

package test is
    procedure clock(signal clock : inout std_logic; running : in boolean);
    
    procedure memory(
        signal clk : in std_logic;
        current_address : in std_logic_vector(data_in_sz - 1 downto 0);
        current_wz_base : in wz_base_array;
        actual_clr : inout boolean;
        signal actual_address : inout std_logic_vector(data_out_sz - 1 downto 0);
        en, we : in std_logic;
        mem_address : in std_logic_vector;
        write_data : in std_logic_vector(data_out_sz - 1 downto 0);
        signal read_data : out std_logic_vector(data_in_sz - 1 downto 0)
    );
    
    procedure run_test(
        signal running : out boolean;
        signal current_test_address : out test_address_r;
        signal current_wz_base : out wz_base_array;
        signal reset, start : out std_logic;
        actual_clr : out boolean;
        signal actual_address : in std_logic_vector(data_out_sz - 1 downto 0);
        signal done : in std_logic
    );
end test;

package body test is
    function sl_to_chr(sl : std_logic) return character is
        variable c : character;
        
        begin
            case sl is
                when 'U' => c := 'U';
                when 'X' => c := 'X';
                when '0' => c := '0';
                when '1' => c := '1';
                when 'Z' => c := 'Z';
                when 'W' => c := 'W';
                when 'L' => c := 'L';
                when 'H' => c := 'H';
                when '-' => c := '-';
            end case;
            return c;
    end function sl_to_chr;
    
    function slv_to_str(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
        variable r : integer;
        
        begin
            r := 1;
            for i in slv'range loop
                result(r) := sl_to_chr(slv(i));
                r := r + 1;
            end loop;
            return result;
    end function slv_to_str;
    
    procedure clock(signal clock : inout std_logic; running : in boolean) is
        begin
            if running then
                clock <= not clock after clock_period / 2;
            else
                clock <= '0';
            end if;
    end procedure clock;
    
    procedure run_test(
        signal running : out boolean;
        signal current_test_address : out test_address_r;
        signal current_wz_base : out wz_base_array;
        signal reset, start : out std_logic;
        actual_clr : out boolean;
        signal actual_address : in std_logic_vector(data_out_sz - 1 downto 0);
        signal done : in std_logic
    ) is
        constant clock_period : time := 100 ns;
        variable passed : natural := 0;
        variable current_test_address_v: test_address_r;
    
        begin
            for test_n in test_data'range loop
                wait for clock_period;
                current_wz_base <= test_data(test_n).wz_base;
                current_test_address <= ((others => 'U'), (others => 'U'));
                reset <= '1';
                wait for clock_period;
                reset <= '0';
                for addr_n in test_data(0).test_address'range loop
                    wait for clock_period;
                    current_test_address_v := test_data(test_n).test_address(addr_n);
                    current_test_address <= current_test_address_v;
                    actual_clr := true;
                    start <= '1';
                    wait until done = '1';
                    if actual_address = current_test_address_v.expected then
                        passed := passed + 1;
                    else
                        report "TEST " & integer'image(test_n) & "." & integer'image(addr_n) &
                               " FAILED" & lf &
                               "Expected " & slv_to_str(current_test_address_v.expected) & ", " &
                               "got " & slv_to_str(actual_address)
                        severity error;
                    end if;
                    wait for clock_period;
                    start <= '0';
                    wait until done = '0';
                end loop;
            end loop;
            report "TEST COMPLETED" & lf &
                   "PASSED: " & integer'image(passed) & lf &
                   "FAILED: " & integer'image(test_data'length * test_data(0).test_address'length - passed)
            severity note;
            running <= false;
    end procedure run_test;
    
    procedure memory(
        signal clk : in std_logic;
        current_address : in std_logic_vector(data_in_sz - 1 downto 0);
        current_wz_base : in wz_base_array;
        actual_clr : inout boolean;
        signal actual_address : inout std_logic_vector(data_out_sz - 1 downto 0);
        en, we : in std_logic;
        mem_address : in std_logic_vector;
        write_data : in std_logic_vector(data_out_sz - 1 downto 0);
        signal read_data : out std_logic_vector(data_in_sz - 1 downto 0)
    ) is
        variable mem_addr_int : natural;
        variable read_data_v : std_logic_vector(read_data'range);
        
        begin
            if rising_edge(clk) then
                if actual_clr then
                    actual_address <= (others => 'U');
                    actual_clr := false;
                end if;
                if en = '1' then
                    mem_addr_int := to_integer(unsigned(mem_address));
                    if mem_addr_int = current_wz_base'high + 2 then
                        if we = '1' then
                            actual_address <= write_data;
                            read_data_v := write_data(read_data'range);
                        else
                            report "Read from address " & integer'image(mem_addr_int) severity warning;
                            read_data_v := actual_address(read_data'range);
                        end if;
                    else
                        if we = '1' then
                         report "Write to illegal address " & integer'image(mem_addr_int) severity error;
                        end if;
                        if mem_addr_int = current_wz_base'high + 1 then
                            read_data_v := current_address;
                        elsif mem_addr_int <= current_wz_base'high then
                            read_data_v := current_wz_base(mem_addr_int);
                        else
                            report "Read from illegal address " & integer'image(mem_addr_int) severity error;
                            read_data_v := (others => 'U');
                        end if;
                    end if;
                    read_data <= read_data_v after mem_delay;
                end if;
            end if;
    end procedure memory;
end test;
