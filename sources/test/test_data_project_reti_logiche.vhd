library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

package test_data is
    constant clock_period  : time     := 100 ns;
    constant mem_delay     : time     := 1 ns;
    constant data_sz       : positive := 8;
    constant log_Dwz       : natural  := 2;
    constant log_Nwz       : natural  := work.common.log_Nwz(log_Dwz, data_sz);
    constant address_count : natural  := 2;
    constant reset_count   : natural  := 1;
    
    type wz_base_array is array (0 to 2 ** log_Nwz - 1) of std_logic_vector(data_sz - 1 downto 0);
    type test_address_r is record
        address, expected  : std_logic_vector(data_sz - 1 downto 0);
    end record test_address_r;
    type test_address_array is array(0 to address_count - 1) of test_address_r;
    type test_r is record
        wz_base : wz_base_array;
        test_address : test_address_array;
    end record test_r;
    type test_array is array(1 to reset_count) of test_r;
    
    constant test_data : test_array := (
        1 => (
            wz_base => (
                x"04",
                x"0D",
                x"16",
                x"1F",
                x"26",
                x"2D",
                x"4D",
                x"5b"
            ),
            test_address => (
                ("00101010", "00101010"),
                ("00100001", "10110100")
            )
        )
    );
end test_data;
