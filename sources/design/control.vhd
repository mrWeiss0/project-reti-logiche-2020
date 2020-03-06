library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

entity control is
    generic(
        log_Nwz : natural
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        done     : out std_logic;
        working  : out std_logic;
        wz_id    : out std_logic_vector(log_Nwz + 1 - 1 downto 0);
        mem_addr : out std_logic_vector(log_Nwz + 1 - 1 downto 0)
    );
end control;

architecture structural of control is
    
    begin
        
end structural;
