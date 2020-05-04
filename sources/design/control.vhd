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
        Nwz : positive
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        done     : out std_logic;
        wz_id    : out std_logic_vector(log2(Nwz) - 1 downto 0);
        convert  : out std_logic;
        mem_addr : out std_logic_vector(log2(Nwz + 2) - 1 downto 0);
        mem_en   : out std_logic;
        mem_we   : out std_logic
    );
end control;

architecture structural of control is
    signal working_s, convert_s, write_s, done_s : std_logic;
    signal wz_id_st : unsigned(log2(Nwz + 1) - 1 downto 0);
    signal wz_id_incr, wz_id_pad : unsigned(mem_addr'range);
    signal wz_id_cur : std_logic_vector(wz_id'range);
    signal all_wz : std_logic;
    
    begin
        working_s <= start and not done_s;
        done <= done_s;
        wz_id <= wz_id_cur;
        wz_id_pad(wz_id_pad'high downto wz_id_st'high + 1) <= (others => '0');
        wz_id_pad(wz_id_st'range) <= wz_id_st;
        wz_id_incr <= wz_id_pad + 1;
        all_wz <= '1' when to_integer(wz_id_st) >= Nwz else '0';
        mem_addr <=
            std_logic_vector(wz_id_incr) when write_s = '1' else
            std_logic_vector(wz_id_pad);
        mem_en <= working_s;
        mem_we <= write_s;
        convert <= convert_s;
        process(clk) is
            begin
                if rising_edge(clk) then
                    -- working zone id increment
                    if rst = '1' then
                        wz_id_st <= (others => '0');
                    elsif (working_s and not all_wz) = '1' then
                        wz_id_st <= wz_id_incr(wz_id_st'range);
                    end if;
                    -- working zone id delay
                    if rst = '1' then
                        wz_id_cur <= (others => '0');
                        convert_s <= '0';
                    elsif working_s = '1' then
                        wz_id_cur <= std_logic_vector(wz_id_st(wz_id_cur'range));
                        convert_s <= all_wz;
                    end if;
                    -- write trigger
                    if rst = '1' then
                        write_s <= '0';
                    elsif working_s = '1' then
                        write_s <= all_wz and not write_s;
                    end if;
                    -- done trigger
                    if rst = '1' then
                        done_s <= '0';
                    else
                        done_s <= start and (write_s or done_s);
                    end if;
                end if;
        end process;
end structural;
