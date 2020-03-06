library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

entity main is
    generic(
        data_sz : positive;
        log_Dwz : natural
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        data_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
        done     : out std_logic;
        mem_addr : out std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1 downto 0);
        mem_en   : out std_logic;
        mem_we   : out std_logic;
        data_out : out std_logic_vector(data_sz - 1 downto 0)
    );
end main;

architecture structural of main is
    component control is
        generic(
            log_Nwz : natural := log_Nwz(log_Dwz, data_sz)
        );
        port(
            clk, rst : in  std_logic;
            start    : in  std_logic;
            done     : out std_logic;
            working  : out std_logic;
            wz_id    : out std_logic_vector(log_Nwz + 1 - 1 downto 0);
            mem_addr : out std_logic_vector(log_Nwz + 1 - 1 downto 0)
        );
    end component;    
    component convert is
        generic(
            data_sz : positive := data_sz;
            log_Dwz : natural := log_Dwz
        );
        port(
            clk, rst    : in  std_logic;
            working     : in  std_logic;
            wz_id       : in  std_logic_vector(log_Nwz(log_Dwz, data_sz) + 1 - 1  downto 0);
            address_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            address_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component;
    signal working : std_logic;
    signal wz_id : std_logic_vector(mem_addr'range);

    begin
        mem_en <= working;
        mem_we <= wz_id(wz_id'high);
        control_u : control
            port map(
                clk => clk,
                rst => rst,
                start => start,
                done => done,
                working => working,
                wz_id => wz_id,
                mem_addr => mem_addr
            );
        convert_u : convert
            port map(
                clk => clk,
                rst => rst,
                working => working,
                wz_id => wz_id,
                address_in => data_in,
                address_out => data_out
            );
end structural;
