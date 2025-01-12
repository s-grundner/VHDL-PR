library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

-- entity

entity delta_adc is
    generic (
        ADC_RESOLUTION : natural := 8;
        SAMPLING_PSC   : natural := 4;
        MAX_CNT_VAL    : natural
    );
    port (
        clk_i			 : in std_ulogic;
        rst_i			 : in std_ulogic;
        pwm_o 			 : out std_logic;
        adc_valid_strb_o : out std_ulogic := '0';
        adc_val_o 		 : out unsigned(ADC_RESOLUTION-1 downto 0);
        comp_i 		     : in std_logic
    );
end delta_adc;

-- architecture

architecture behav of delta_adc is

    signal on_cnt_val, next_on_cnt_val        : unsigned(ADC_RESOLUTION-1 downto 0) := (others => '0');
    signal sampling_strb, next_adc_valid_strb : std_ulogic := '0';

begin

    pwm_ent : entity work.pwm(behav)
        generic map (
            CNT_LEN => ADC_RESOLUTION
        )
        port map (
            clk_i => clk_i,
            rst_i => rst_i,
            period_cnt_val_i => to_unsigned(MAX_CNT_VAL, ADC_RESOLUTION),
            on_cnt_val_i => on_cnt_val,
            pwm_o => pwm_o
        );
    
    sampling_strb_ent : entity work.strb_generator(behav)
        generic map (
            PRESCALER => SAMPLING_PSC
        )
        port map (
            clk_i  => clk_i,
            rst_i  => rst_i,
            strb_o => sampling_strb
        );

    reg_seq : process(clk_i, rst_i) is
    begin
        if rst_i = '1' then
            adc_val_o <= (others => '0');
            next_adc_valid_strb <= '0';
        elsif rising_edge(clk_i) then
            on_cnt_val <= next_on_cnt_val;
            adc_val_o <= next_on_cnt_val;
            next_adc_valid_strb <= sampling_strb;
        end if;
    end process reg_seq;

    adc_comb : process (sampling_strb, comp_i, on_cnt_val) is
    begin
        next_on_cnt_val <= on_cnt_val;
        if sampling_strb = '1' then
            next_on_cnt_val <= on_cnt_val + 1 when comp_i = '1' else on_cnt_val - 1;
        end if;
    end process adc_comb;
    
    adc_valid_strb_o <= next_adc_valid_strb;

end behav;