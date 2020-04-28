library ieee;
use ieee.std_logic_1164.all;
use work.test_data.all;
use work.test.all;

entity main_tb is
end main_tb;

architecture test of main_tb is
    component main is
        generic(
            data_sz : positive := data_sz;
            log_Dwz : natural := log_Dwz
        );
        port(
            clk, rst : in  std_logic;
            start    : in  std_logic;
            data_in  : in  std_logic_vector(data_sz - 1 - 1 downto 0);
            done     : out std_logic;
            mem_addr : out std_logic_vector(log_Nwz + 1 - 1 downto 0);
            mem_en   : out std_logic;
            mem_we   : out std_logic;
            data_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component;
    
    signal running : boolean := true;
    signal clk : std_logic := '1';
    signal rst, start : std_logic;
    signal data_in : std_logic_vector(data_sz - 1 downto 0);
    signal done : std_logic;
    signal mem_addr : std_logic_vector(log_Nwz + 1 - 1 downto 0);
    signal mem_en, mem_we : std_logic;
    signal data_out : std_logic_vector(data_sz - 1 downto 0);
    
    signal wz_base_curr : wz_base_array;
    signal test_address_curr : test_address_r;
    shared variable actual_clr : boolean := false;
    signal actual : std_logic_vector(data_out'range);
    
    begin
        clock(clk, running);
        run_test(
            running => running,
            current_test_address => test_address_curr,
            current_wz_base => wz_base_curr,
            reset => rst,
            start => start,
            actual_clr => actual_clr,
            actual_address => actual,
            done => done
        );
        memory(
            clk => clk,
            current_address => test_address_curr.address,
            current_wz_base => wz_base_curr,
            actual_clr => actual_clr,
            actual_address => actual,
            en => mem_en ,
            we => mem_we,
            mem_address => mem_addr,
            write_data => data_out,
            read_data => data_in
        );
        uut : main
            port map(
                clk      => clk,
                rst      => rst,
                start    => start,
                data_in  => data_in(data_sz - 1 - 1 downto 0),
                done     => done,
                mem_addr => mem_addr,
                mem_en   => mem_en,
                mem_we   => mem_we,
                data_out => data_out
            );
end test;
