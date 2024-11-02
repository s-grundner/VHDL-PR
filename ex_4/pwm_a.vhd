library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

architecture behav of pwm is

	signal count : unsigned(COUNTER_LEN-1 downto 0);
	signal count_reset_flag : std_ulogic := '0';
	signal next_pwm : std_ulogic;
	signal prev_ON_counter_val : unsigned(COUNTER_LEN-1 downto 0) := (others => '0');

begin
	-- counter for the PWM

	counter_ent : entity work.counter(behav)
		generic map (
			COUNTER_LEN => COUNTER_LEN
		)
		port map (
			clk_i => clk_i,
			rst_i => rst_i,
			counter_rst_strobe_i => count_reset_flag,
			counter_o => count
		);
	
	-- PWM logic

	reg_sequential : process (clk_i, rst_i) is
	begin
		if rst_i = '1' then
			PWM_o <= '0';
		elsif rising_edge(clk_i) then	
			PWM_o <= next_pwm;
			prev_ON_counter_val <= ON_counter_val_i;
		end if;
	end process reg_sequential;

	pwm_combinatorial : process (count, ON_counter_val_i) is
	begin
		if count < ON_counter_val_i then
			next_pwm <= '1';
		else
			next_pwm <= '0';
		end if;
	end process pwm_combinatorial;

	clr_combinatorial : process (count, Period_counter_val_i) is
	begin
		if count = Period_counter_val_i-1 then
			count_reset_flag <= '1';
		else
			count_reset_flag <= '0';
		end if;
	end process clr_combinatorial;

end behav;