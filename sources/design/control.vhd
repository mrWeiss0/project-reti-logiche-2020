library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    signal working_s, done_s : std_logic;
    signal wz_id_st : unsigned(log_Nwz + 1 - 1 downto 0);
    signal wz_id_cur : std_logic_vector(log_Nwz + 1 - 1 downto 0);
    
    begin
        working_s <= start and not done_s;
        working <= working_s;
        done <= done_s;
        wz_id <= wz_id_cur;
        mem_addr <= std_logic_vector(wz_id_st);
        process(clk) is
            begin
                if rising_edge(clk) then
                    -- working zone id increment
                    if rst = '1' then
                        wz_id_st <= (others => '0');
                    elsif (working_s and not wz_id_st(wz_id_st'high)) = '1' then
                        wz_id_st <= wz_id_st + 1;
                    end if;
                    -- working zone id delay
                    if (rst or done_s) = '1' then
                        wz_id_cur <= (others => '0');
                    elsif working_s = '1' then
                        wz_id_cur <= std_logic_vector(wz_id_st);
                    end if;
                    -- done trigger
                    if rst = '1' then
                        done_s <= '0';
                    else
                        done_s <= start and (wz_id_cur(wz_id_cur'high) or done_s);
                    end if;
                end if;
        end process;
end structural;
