library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
    generic(
        log_Nwz : natural
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        done     : out std_logic;
        wz_id    : out std_logic_vector(log_Nwz + 1 - 1 downto 0);
        mem_addr : out std_logic_vector(log_Nwz + 1 - 1 downto 0);
        mem_en   : out std_logic;
        mem_we   : out std_logic
    );
end control;

architecture structural of control is
    signal working, done_s, convert : std_logic;
    signal wz_id_st, wz_id_incr : unsigned(wz_id'range);
    signal wz_id_cur : std_logic_vector(wz_id'range);
    
    begin
        working <= start and not done_s;
        done <= done_s;
        wz_id <= wz_id_cur;
        wz_id_incr <= wz_id_st + 1;
        mem_addr <=
            std_logic_vector(wz_id_incr) when convert = '1' else
            std_logic_vector(wz_id_st);
        mem_en <= working;
        mem_we <= convert;
        process(clk) is
            begin
                if rising_edge(clk) then
                    -- working zone id increment
                    if rst = '1' then
                        wz_id_st <= (others => '0');
                    elsif (working and not wz_id_st(wz_id_st'high)) = '1' then
                        wz_id_st <= wz_id_incr;
                    end if;
                    -- working zone id delay
                    if rst = '1' then
                        wz_id_cur <= (others => '0');
                    elsif working = '1' then
                        wz_id_cur <= std_logic_vector(wz_id_st);
                    end if;
                    -- convert trigger
                    if (rst or convert) = '1' then
                        convert <= '0';
                    elsif working = '1' then
                        convert <= wz_id_st(wz_id_st'high);
                    end if;
                    -- done trigger
                    if rst = '1' then
                        done_s <= '0';
                    else
                        done_s <= start and (convert or done_s);
                    end if;
                end if;
        end process;
end structural;
