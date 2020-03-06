library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

entity main is
    generic(
        data_sz : positive;
        log_Dwz : natural
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        data_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
        done     : out std_logic;
        mem_addr : out std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1 downto 0);
        mem_en   : out std_logic;
        mem_we   : out std_logic;
        data_out : out std_logic_vector(data_sz - 1 downto 0)
    );
end main;

architecture structural of main is
    begin
end structural;
