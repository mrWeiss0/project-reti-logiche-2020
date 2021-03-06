library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

-- This entity is a wrapper for the main entity.
-- It defines all the parameters given in the project specifications
-- and connects the relevant ranges of the buses to the
-- instantiated component.

entity project_reti_logiche is
    port(
        i_clk     : in  std_logic;
        i_start   : in  std_logic;
        i_rst     : in  std_logic;
        i_data    : in  std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture structural of project_reti_logiche is
    constant data_sz : positive := o_data'length;
    constant Dwz : positive := 4;
    constant Nwz : positive := 8;
    component main is
        generic(
            data_sz : positive := data_sz;
            Dwz : positive := Dwz;
            Nwz : positive := Nwz
        );
        port(
            clk, rst : in  std_logic;
            start    : in  std_logic;
            data_in  : in  std_logic_vector(data_sz - 2 downto 0);
            done     : out std_logic;
            mem_addr : out std_logic_vector(log2(Nwz + 2) - 1 downto 0);
            mem_en   : out std_logic;
            mem_we   : out std_logic;
            data_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component;

    begin
        o_address(o_address'high downto log2(Nwz + 2)) <= (others => '0');
        main_u : main
            port map(
                clk      => i_clk,
                rst      => i_rst,
                start    => i_start,
                data_in  => i_data(data_sz - 2 downto 0),
                done     => o_done,
                mem_addr => o_address(log2(Nwz + 2) - 1 downto 0),
                mem_en   => o_en,
                mem_we   => o_we,
                data_out => o_data
            );
end structural;
