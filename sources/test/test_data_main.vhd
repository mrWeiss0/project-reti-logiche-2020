library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

package test_data is
    constant data_in_sz : positive := 3;
    constant data_out_sz : positive := 4;
    constant log_Dwz : natural := 1;
    constant log_Nwz : natural := work.common.log_Nwz(log_Dwz, data_out_sz);
    constant Nwz : positive := 2 ** log_Nwz;
    constant reset_count : natural := 4;
    constant address_count : natural := 8;
    
    type wz_base_array is array (0 to Nwz - 1) of std_logic_vector(data_in_sz - 1 downto 0);
    type test_address_r is record
        address  : std_logic_vector(data_in_sz - 1 downto 0);
        expected : std_logic_vector(data_out_sz - 1 downto 0);
    end record test_address_r;
    type test_address_array is array(0 to address_count - 1) of test_address_r;
    type test_r is record
        wz_base : wz_base_array;
        test_address : test_address_array;
    end record test_r;
    type test_array is array(1 to reset_count) of test_r;
    
    constant clock_period : time := 100 ns;
    constant mem_delay : time := 1 ns;
    
    constant test_data : test_array := (
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
end test_data;
