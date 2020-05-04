library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

-- This entity compares the address against a single working zone.
-- If match is set to '1', the address matched and
-- address_out is the converted address, otherwise
-- address is not in the working zone and output is zeroed.

entity encode is
    generic(
        data_sz : positive;
        Dwz : positive;
        id : natural
    );
    port(
        address_in  : in  std_logic_vector(data_sz - 2 downto 0);
        wz_base     : in  std_logic_vector(data_sz - 2 downto 0);
        address_out : out std_logic_vector(data_sz - 2 downto 0);
        match       : out std_logic
    );
end encode;

architecture dataflow of encode is
    signal diff : signed(address_in'high + 1 downto address_in'low);
    signal offset : std_logic_vector(log2(Dwz) - 1 downto 0);
    signal offset_sel : std_logic_vector(Dwz - 1 downto 0);
    signal id_s : std_logic_vector(data_sz - 2 downto Dwz);
    signal match_s : std_logic;
    signal match_slv : std_logic_vector(address_out'range);
    function offset_decode(offset : std_logic_vector) return std_logic_vector is
        variable offset_sel_t : std_logic_vector(2**offset'length - 1 downto 0);
        
        begin
            offset_sel_t := (others => '0');
            offset_sel_t(to_integer(unsigned(offset))) := '1';
            return offset_sel_t;
    end function;
    
    begin
        diff <= signed('0' & address_in) - signed('0' & wz_base);
        offset <= std_logic_vector(diff(offset'range));
        offset_sel <= offset_decode(offset)(offset_sel'range);
        match_s <= '1' when (to_integer(diff) >= 0) and (to_integer(diff) < Dwz) else '0';
        match <= match_s;
        match_slv <= (others => match_s);
        id_s <= std_logic_vector(to_unsigned(id, id_s'length));
        address_out <= (id_s & offset_sel) and match_slv;
end dataflow;
