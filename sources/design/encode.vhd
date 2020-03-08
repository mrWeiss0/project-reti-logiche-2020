library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

entity encode is
    generic(
        data_sz : positive;
        id : natural
    );
    port(
        address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
        wz_base     : in  std_logic_vector(data_sz - 1 - 1 downto 0);
        address_out : out std_logic_vector(data_sz - 1 downto 0);
        valid       : out std_logic
    );
end encode;

architecture dataflow of encode is
    
    begin
        
end dataflow;
