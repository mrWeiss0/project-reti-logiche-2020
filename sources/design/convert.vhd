library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

entity convert is
    generic(
        data_sz : positive;
        log_Dwz : natural
    );
    port(
        clk, rst    : in  std_logic;
        working     : in  std_logic;
        wz_id       : in  std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1 downto 0);
        address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
        address_out : out std_logic_vector(data_sz - 1 downto 0)
    );
end convert;

architecture structural of convert is
    
    begin
        
end structural;
