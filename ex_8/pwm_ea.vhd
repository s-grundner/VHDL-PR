library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

-- entity

entity pwm is
    generic (
        CNT_LEN : natural
    );
    port (
        clk_i 			 : in std_ulogic;
        rst_i 			 : in std_ulogic;
        period_cnt_val_i : in unsigned(CNT_LEN-1 downto 0);
        on_cnt_val_i 	 : in unsigned(CNT_LEN-1 downto 0);
        pwm_o 			 : out std_ulogic
    );
end entity pwm;

-- architecture

architecture behav of pwm is

    signal cnt : unsigned(CNT_LEN-1 downto 0);
    signal cnt_rst_flag : std_ulogic := '0';

begin
    cnt_ent : entity work.counter(behav)
        generic map (
            CNT_LEN => CNT_LEN
        )
        port map (
            clk_i      => clk_i,
            rst_i      => rst_i,
            sync_rst_i => cnt_rst_flag,
            cnt_o      => cnt
        );
    
    pwm_o <= '1' when cnt < on_cnt_val_i else '0';
    cnt_rst_flag <= '1' when cnt = period_cnt_val_i-1 else '0';

end behav;