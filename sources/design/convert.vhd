library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
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
    constant Nwz : positive := 2 ** (wz_id'length - 1);
    component encode is
        generic(
            data_sz : positive := data_sz;
            id : natural
        );
        port(
            address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            wz_base     : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            address_out : out std_logic_vector(data_sz - 1 downto 0);
            valid       : out std_logic
        );
    end component;
    signal wz_id_sel : std_logic_vector(Nwz - 1 downto 0);
    type wz_base_array is array(wz_id_sel'range) of std_logic_vector(address_in'range);
    signal wz_base : wz_base_array;
    type encoded_array is array(wz_id_sel'range) of std_logic_vector(address_out'range);
    signal encoded : encoded_array;
    signal valid : std_logic_vector(encoded'range);
    
    begin
        process(wz_id) is
            variable wz_id_sel_t, wz_id_high : std_logic_vector(wz_id_sel'range);
            
            begin
                wz_id_sel_t := (others => '0');
                wz_id_sel_t(to_integer(unsigned(wz_id(wz_id'high - 1 downto 0)))) := '1';
                wz_id_high := (others => wz_id(wz_id'high));
                wz_id_sel_t := wz_id_sel_t and not wz_id_high;
                wz_id_sel <= wz_id_sel_t;
        end process;
        process(clk) is
            begin
                if rising_edge(clk) then
--                    if rst = '1' then
--                        wz_id_st <= (others => '0');
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
                    valid => valid(i)
                );
            address_out <= encoded(i) when valid(i) = '1' else (others => 'Z');
        end generate encode_l;
        address_out <= '0' & address_in when nor_reduce(valid) = '1' else (others => 'Z');
end structural;
