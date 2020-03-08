library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.common.all;

entity encode is
    generic(
        data_sz : positive;
        log_Dwz : natural;
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
    signal diff : signed(address_in'length + 1 - 1 downto 0);
    signal offset : std_logic_vector(log_Dwz - 1 downto 0);
    signal diff_limit :std_logic_vector(diff'high downto offset'high + 1);
    signal offset_sel : std_logic_vector(2 ** log_Dwz - 1 downto 0);
    signal id_s : std_logic_vector(log_Nwz(log_Dwz, data_sz) - 1 downto 0);
    
    begin
        diff <= signed('0' & address_in) - signed('0' & wz_base);
        diff_limit <= std_logic_vector(diff(diff_limit'range));
        offset <= std_logic_vector(diff(offset'range));
        valid <= nor_reduce(diff_limit);
        id_s <= std_logic_vector(to_unsigned(id, id_s'length));
        address_out <= '1' & id_s & offset_sel;
        process(offset) is
            variable offset_sel_t : std_logic_vector(offset_sel'range);
            
            begin
                offset_sel_t := (others => '0');
                offset_sel_t(to_integer(unsigned(offset))) := '1';
                offset_sel <= offset_sel_t;
        end process;
end dataflow;
