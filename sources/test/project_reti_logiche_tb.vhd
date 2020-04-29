library ieee;
use ieee.std_logic_1164.all;
use work.test_data.all;
use work.test.all;

entity project_reti_logiche_tb is
end project_reti_logiche_tb;

architecture test of project_reti_logiche_tb is
    component project_reti_logiche is
        port(
            i_clk     : in  std_logic;
            i_start   : in  std_logic;
            i_rst     : in  std_logic;
            i_data    : in  std_logic_vector(7 downto 0);
            o_address : out std_logic_vector(15 downto 0);
            o_done    : out std_logic;
            o_en      : out std_logic;
            o_we      : out std_logic;
            o_data    : out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal running : boolean := true;
    signal clk : std_logic := '0';
    signal rst, start : std_logic := '0';
    signal data_in : std_logic_vector(data_sz - 1 downto 0) := (others => '0');
    signal done : std_logic;
    signal mem_addr : std_logic_vector(15 downto 0);
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
        uut : project_reti_logiche
            port map(
                i_clk     => clk,
                i_rst     => rst,
                i_start   => start,
                i_data    => data_in,
                o_done    => done,
                o_address => mem_addr,
                o_en      => mem_en,
                o_we      => mem_we,
                o_data    => data_out
            );
end test;
