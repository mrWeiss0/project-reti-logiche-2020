library ieee;
use ieee.std_logic_1164.all;

entity control_tb is
end control_tb;

architecture test of control_tb is
    constant clk_period : time := 100 ns;
    constant log_Nwz : natural := 2;
    component control is
        generic(
            log_Nwz : natural := log_Nwz
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
    end component;  
    signal clk, rst, start : std_logic := '0';
    signal done : std_logic;
    signal mem_en, mem_we : std_logic;
    signal wz_id, mem_addr : std_logic_vector(log_Nwz + 1 - 1  downto 0);
    
    begin
        clk <= not clk after clk_period / 2;
        uut : control
            port map(
                clk => clk,
                rst => rst,
                start => start,
                done => done,
                wz_id => wz_id,
                mem_addr => mem_addr,
                mem_en => mem_en,
                mem_we => mem_we
            );
        process is
            begin
                for i in 0 to 2 loop
                    wait for clk_period / 2;
                    rst <= '1';
                    wait for clk_period;
                    rst <= '0';
                    for j in 0 to 2 loop
                        wait for 2 * clk_period;
                        start <= '1';
                        wait until done = '1';
                        wait for clk_period;
                        start <= '0';
                    end loop;
                end loop;
                wait;
        end process;
end test;
