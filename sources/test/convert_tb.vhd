library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity convert_tb is
end convert_tb;

architecture test of convert_tb is
    constant clk_period : time := 100 ns;
    constant data_sz : positive := 4;
    constant Dwz : positive := 2;
    constant Nwz : positive := 2;
    component convert is
        generic(
            data_sz : positive := data_sz;
            Dwz : positive := Dwz;
            Nwz : positive := Nwz
        );
        port(
            clk         : in  std_logic;
            wz_id       : in  std_logic_vector(log2(Nwz) - 1 downto 0);
            convert     : in  std_logic;
            address_in  : in  std_logic_vector(data_sz - 2 downto 0);
            address_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component; 
    signal clk : std_logic := '0';
    signal convert_s : std_logic;
    signal wz_id : std_logic_vector(log2(Nwz) - 1 downto 0) := (others => '0');
    signal address_in : std_logic_vector(data_sz - 2 downto 0);
    signal address_out : std_logic_vector(data_sz - 1 downto 0);
    type wz_base_subarray is array(0 to Nwz - 1) of std_logic_vector(address_in'range);
    type wz_base_array is array(0 to 1) of wz_base_subarray;
    signal wz_base : wz_base_array := (
        ("001", "100"), -- good
        ("101", "110")  -- collision
    );
    
    begin
        clk <= not clk after clk_period / 2;
        uut : convert
            port map(
                clk => clk,
                wz_id => wz_id,
                convert => convert_s,
                address_in => address_in,
                address_out => address_out
            );
        process is
            begin
                for k in wz_base'range loop
                    wait for clk_period;
                    convert_s <= '0';
                    for i in wz_base(0)'range loop
                        wz_id <= std_logic_vector(to_unsigned(i, wz_id'length));
                        address_in <= wz_base(k)(i);
                        wait for clk_period;
                    end loop;
                    convert_s <= '1';
                    for i in 0 to 2 ** (address_in'length) - 1 loop
                        address_in <= std_logic_vector(to_unsigned(i, address_in'length));
                        wait for clk_period;
                    end loop;
                end loop;
                wait;
        end process;
end test;
