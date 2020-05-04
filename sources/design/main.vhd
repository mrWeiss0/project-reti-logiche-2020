library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

-- Main entity of the project.
-- consists of a control component, for the input, output and control logic,
-- and a convert component, that stores the data and computes the result.

entity main is
    generic(
        data_sz : positive;
        Dwz : positive;
        Nwz : positive
    );
    port(
        clk, rst : in  std_logic;
        start    : in  std_logic;
        data_in  : in  std_logic_vector(data_sz - 2 downto 0);
        done     : out std_logic;
        mem_addr : out std_logic_vector(log2(Nwz + 2) - 1 downto 0);
        mem_en   : out std_logic;
        mem_we   : out std_logic;
        data_out : out std_logic_vector(data_sz - 1 downto 0)
    );
end main;

architecture structural of main is
    component control is
        generic(
            Nwz : positive := Nwz
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
    end component;    
    component convert is
        generic(
            data_sz : positive := data_sz;
            Dwz : positive := Dwz;
            Nwz : positive := Nwz
        );
        port(
            clk         : in  std_logic;
            wz_id       : in  std_logic_vector(log2(Nwz) - 1 downto 0);
            convert     : in  std_logic;
            address_in  : in  std_logic_vector(data_sz - 2 downto 0);
            address_out : out std_logic_vector(data_sz - 1 downto 0)
        );
    end component;
    signal wz_id : std_logic_vector(log2(Nwz) - 1 downto 0);
    signal convert_s : std_logic;

    begin
        assert Nwz <= 2**(data_sz - 1 - Dwz)
        report "Nwz = " & integer'image(Nwz) &
               " exceeded maximum value " & integer'image(2**(data_sz - 1 - Dwz))
        severity failure;
        control_u : control
            port map(
                clk => clk,
                rst => rst,
                start => start,
                done => done,
                wz_id => wz_id,
                convert => convert_s,
                mem_addr => mem_addr,
                mem_en => mem_en,
                mem_we => mem_we
            );
        convert_u : convert
            port map(
                clk => clk,
                wz_id => wz_id,
                convert => convert_s,
                address_in => data_in,
                address_out => data_out
            );
end structural;
