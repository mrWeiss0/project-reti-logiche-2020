library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity main_tb is
end main_tb;

architecture test of main_tb is
    constant clk_period : time := 100 ns;
    constant data_sz : positive := 4;
    constant log_Dwz : natural := 1;
    constant log_Nwz : natural := log_Nwz(log_Dwz, data_sz);
    function sl_to_chr(sl: std_logic) return character is
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
    function slv_to_str(slv: std_logic_vector) return string is
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
    component main is
        generic(
            data_sz : positive := data_sz;
            log_Dwz : natural := log_Dwz
        );
        port(
            clk, rst : in  std_logic;
            start    : in  std_logic;
            data_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            done     : out std_logic;
            mem_addr : out std_logic_vector(work.common.log_Nwz(log_Dwz, data_sz) + 1 - 1 downto 0);
            mem_en   : out std_logic;
            mem_we   : out std_logic;
            data_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component;
    signal running : boolean := true;
    signal clk : std_logic := '1';
    signal rst, start : std_logic;
    signal data_in : std_logic_vector(data_sz - 1 - 1 downto 0);
    signal done : std_logic;
    signal mem_addr : std_logic_vector(log_Nwz + 1 - 1 downto 0);
    signal mem_en, mem_we : std_logic;
    signal data_out : std_logic_vector(data_sz - 1 downto 0);
    
    constant reset_count : natural := 4;
    constant address_count : natural := 8;
    type wz_base_array is array(0 to 2 ** log_Nwz - 1) of std_logic_vector(data_in'range);
    type test_address_r is record
        address  : std_logic_vector(data_in'range);
        expected : std_logic_vector(data_out'range); 
    end record test_address_r;
    type test_address_array is array(0 to address_count - 1) of test_address_r;
    type test_r is record
        wz_base : wz_base_array;
        test_address : test_address_array;
    end record test_r;
    type test_array is array(1 to reset_count) of test_r;
    signal test : test_array := (
        1 => (
            wz_base => (
                "000",
                "110"
            ),
            test_address => (
                ("000", "1001"),
                ("001", "1010"),
                ("010", "0010"),
                ("011", "0011"),
                ("100", "0100"),
                ("101", "0101"),
                ("110", "1101"),
                ("111", "1110")
            )
        ),
        2 => (
            wz_base => (
                "001",
                "011"
            ),
            test_address => (
                ("000", "0000"),
                ("001", "1001"),
                ("010", "1010"),
                ("011", "1101"),
                ("100", "1110"),
                ("101", "0101"),
                ("110", "0110"),
                ("111", "0111")
            )
        ),
        3 => (
            wz_base => (
                "010",
                "100"
            ),
            test_address => (
                ("000", "0000"),
                ("001", "0001"),
                ("010", "1001"),
                ("011", "1010"),
                ("100", "1101"),
                ("101", "1110"),
                ("110", "0110"),
                ("111", "0111")
            )
        ),
        4 => (
            wz_base => (
                "100",
                "010"
            ),
            test_address => (
                ("000", "0000"),
                ("001", "0001"),
                ("010", "1101"),
                ("011", "1110"),
                ("100", "1001"),
                ("101", "1010"),
                ("110", "0110"),
                ("111", "0111")
            )
        )
    );
    signal wz_base_curr : wz_base_array;
    signal test_address_curr : test_address_r;
    shared variable actual_clr : boolean := false;
    signal actual : std_logic_vector(data_out'range);
    
    begin
        clk <= not clk after clk_period / 2 when running else '0';
        main_u : main
            port map(
                clk      => clk,
                rst      => rst,
                start    => start,
                data_in  => data_in,
                done     => done,
                mem_addr => mem_addr,
                mem_en   => mem_en,
                mem_we   => mem_we,
                data_out => data_out
            );
        process is
            variable passed : natural := 0;
        
            begin
                for test_n in test'range loop
                    wait for clk_period;
                    wz_base_curr <= test(test_n).wz_base;
                    test_address_curr <= ((others => 'U'), (others => 'U'));
                    rst <= '1';
                    wait for clk_period;
                    rst <= '0';
                    for addr_n in test(0).test_address'range loop
                        wait for clk_period;
                        test_address_curr <= test(test_n).test_address(addr_n);
                        actual_clr := true;
                        start <= '1';
                        wait until done = '1';
                        if actual = test_address_curr.expected then
                            passed := passed + 1;
                        else
                            report "TEST " & integer'image(test_n) & "." & integer'image(addr_n) &
                                   " FAILED" & lf &
                                   "Expected " & slv_to_str(test_address_curr.expected) & ", " &
                                   "got " & slv_to_str(actual)
                            severity error;
                        end if;
                        wait for clk_period;
                        start <= '0';
                        wait until done = '0';
                    end loop;
                end loop;
                report "TEST COMPLETED" & lf &
                       "PASSED: " & integer'image(passed) & lf &
                       "FAILED: " & integer'image(test'length * test(0).test_address'length - passed)
                severity note;
                running <= false;
                wait;
        end process;
        process(clk) is
            variable mem_addr_int : natural;
            variable read : std_logic_vector(data_in'range);
        
            begin
                if rising_edge(clk) then
                    if actual_clr then
                        actual <= (others => 'U');
                        actual_clr := false;
                    end if;
                    if mem_en = '1' then
                        mem_addr_int := to_integer(unsigned(mem_addr));
                        if mem_addr_int = wz_base_curr'high + 2 then
                            if mem_we = '1' then
                                actual <= data_out;
                                read := data_out(read'range);
                            else
                                report "Read from address " & integer'image(mem_addr_int) severity warning;
                                read := actual(read'range);
                            end if;
                        else
                            if mem_we = '1' then
                             report "Write to illegal address " & integer'image(mem_addr_int) severity error;
                            end if;
                            if mem_addr_int = wz_base_curr'high + 1 then
                                read := test_address_curr.address;
                            elsif mem_addr_int <= wz_base_curr'high then
                                read := wz_base_curr(mem_addr_int);
                            else
                                report "Read from illegal address " & integer'image(mem_addr_int) severity error;
                                read := (others => 'U');
                            end if;
                        end if;
                        data_in <= read after 1 ns;
                    end if;
                end if;
        end process;
end test;
