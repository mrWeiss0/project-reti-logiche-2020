library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

-- Control unit, receives the start signal and manages the states.
-- Its outputs depend on the current execution state and they control
-- the execution of the rest of the circuit.

-- On reset signal, the component is put in a starting state
-- and will read working zones from the memory, then the address
-- to convert. After that the converted address is written in
-- memory in the following position and the done signal is set.
-- Done stays '1' until start is '1', then the component
-- ends in a state ready to read the address to convert.
-- This is because consecutive executions assume unchanged the
-- working zones read at the beginning.

entity control is
    generic(
        log_Nwz : natural
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        done     : out std_logic;
        wz_id    : out std_logic_vector(log_Nwz + 1 - 1 downto 0);
        mem_addr : out std_logic_vector(max(log_Nwz + 1, 2) - 1 downto 0);
        mem_en   : out std_logic;
        mem_we   : out std_logic
    );
end control;

architecture structural of control is
    signal working, done_s, convert : std_logic;
    signal wz_id_st : unsigned(wz_id'range);
    signal wz_id_incr, wz_id_pad : unsigned(mem_addr'range);
    signal wz_id_cur : std_logic_vector(wz_id'range);
    
    begin
        working <= start and not done_s;
        done <= done_s;
        wz_id <= wz_id_cur;
        wz_id_pad <= (mem_addr'high downto wz_id_st'high + 1 => '0') & wz_id_st;
        wz_id_incr <= wz_id_pad + 1;
        mem_addr <=
            std_logic_vector(wz_id_incr) when convert = '1' else
            std_logic_vector(wz_id_pad);
        mem_en <= working;
        mem_we <= convert;
        process(clk) is
            begin
                if rising_edge(clk) then
                    -- working zone id increment
                    if rst = '1' then
                        wz_id_st <= (others => '0');
                    elsif (working and not wz_id_st(wz_id_st'high)) = '1' then
                        wz_id_st <= wz_id_incr(wz_id_st'range);
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
