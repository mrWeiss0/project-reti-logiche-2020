library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity convert_tb is
end convert_tb;

architecture test of convert_tb is
    constant clk_period : time := 100 ns;
    constant data_sz : positive := 4;
    constant log_Dwz : natural := 1;
    component convert is
        generic(
            data_sz : positive := data_sz;
            log_Dwz : natural := log_Dwz
        );
        port(
            clk         : in  std_logic;
            wz_id       : in  std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1  downto 0);
            address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            address_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component; 
    signal clk : std_logic := '0';
    signal wz_id : std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1  downto 0) := (others => '0');
    signal address_in : std_logic_vector(data_sz - 1 - 1 downto 0);
    signal address_out : std_logic_vector(data_sz - 1 downto 0);
    type wz_base_array is array(0 to 2 ** (wz_id'length - 1) - 1) of std_logic_vector(address_in'range);
    signal wz_base : wz_base_array := (
        "001",
        "010"
    );
    
    begin
        clk <= not clk after clk_period / 2;
        uut : convert
            port map(
                clk => clk,
                wz_id => wz_id,
                address_in => address_in,
                address_out => address_out
            );
        process is
            begin
                wait for clk_period / 2;
                for i in wz_base'range loop
                    wz_id <=  std_logic_vector(to_unsigned(i, wz_id'length));
                    address_in <= wz_base(i);
                    wait for clk_period;
                end loop;
                wz_id <=  std_logic_vector(to_unsigned(wz_base'length, wz_id'length));
                for i in 0 to 2 ** (address_in'length) - 1 loop
                    address_in <= std_logic_vector(to_unsigned(i, address_in'length));
                    wait for clk_period;
                end loop;
                wait;
        end process;
end test;
