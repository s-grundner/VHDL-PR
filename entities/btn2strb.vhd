library ieee;
use ieee.std_logic_1164.all;

entity btn2strb is
    port (
        clk_i : in std_ulogic;
        rst_i : in std_ulogic;
        btn_i : in std_ulogic;
        strb_o : out std_ulogic
    );
end btn2strb ;

architecture rtl of btn2strb is
    signal prev_btn, next_strb : std_ulogic;
begin
    next_strb <= '1' when btn_i = '1' and prev_btn = '0' else '0';
    reg_seq : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            strb_o <= '0';
            prev_btn <= '0';
        elsif rising_edge(clk_i) then
            strb_o <= next_strb;
            prev_btn <= btn_i;
        end if;
    end process;
end architecture;