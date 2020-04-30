library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.common.all;

-- Conversion unit, this does the computation and stores the
-- the working zones. It receives the data read from memory
-- and, if it is a working zone address, its id.
-- Output address is valid only if all the working zones are set
-- and they DO NOT OVERLAP.

entity convert is
    generic(
        data_sz : positive;
        log_Dwz : natural
    );
    port(
        clk         : in  std_logic;
        wz_id       : in  std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1 downto 0);
        address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
        address_out : out std_logic_vector(data_sz - 1 downto 0)
    );
end convert;

architecture structural of convert is
    constant Nwz : positive := 2 ** (wz_id'length - 1);
    component encode is
        generic(
            data_sz : positive := data_sz;
            log_Dwz : natural := log_Dwz;
            id : natural
        );
        port(
            address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            wz_base     : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            address_out : out std_logic_vector(data_sz - 1 - 1 downto 0);
            match       : out std_logic
        );
    end component;
    signal wz_id_sel : std_logic_vector(Nwz - 1 downto 0);
    type wz_base_array is array(0 to wz_id_sel'length - 1) of std_logic_vector(address_in'range);
    signal wz_base : wz_base_array;
    type encoded_array is array(wz_base'range) of std_logic_vector(address_in'range);
    signal encoded : encoded_array;
    signal match : std_logic_vector(wz_base'range);
    function id_decode(wz_id : std_logic_vector) return std_logic_vector is
        variable wz_id_sel_t, wz_id_high : std_logic_vector(Nwz - 1 downto 0);
        
        begin
            wz_id_sel_t := (others => '0');
            wz_id_sel_t(to_integer(unsigned(wz_id(wz_id'high - 1 downto 0)))) := '1';
            wz_id_high := (others => wz_id(wz_id'high));
            wz_id_sel_t := wz_id_sel_t and not wz_id_high;
            return wz_id_sel_t;
    end function;
    function reduce_encoded(encoded : encoded_array) return std_logic_vector is
        variable reduced : std_logic_vector(address_in'range);
        
        begin
            reduced := (others => '0');
            for i in encoded'range loop
                reduced := reduced or encoded(i);
            end loop;
            return reduced;
    end function;
    
    begin
        wz_id_sel <= id_decode(wz_id);
        address_out <= ('1' & reduce_encoded(encoded)) when or_reduce(match) = '1' else
                       ('0' & address_in);
        wz_reg : process(clk) is
            begin
                if rising_edge(clk) then
                    for i in wz_base'range loop
                        if (wz_id_sel(i)) = '1' then
                            wz_base(i) <= address_in;
                        end if;
                    end loop;
                end if;
        end process;
        encode_l : for i in wz_base'range generate
            encode_u : encode
                generic map(
                    id => i
                )
                port map(
                    address_in => address_in,
                    wz_base => wz_base(i),
                    address_out => encoded(i),
                    match => match(i)
                );
        end generate encode_l;
end structural;
