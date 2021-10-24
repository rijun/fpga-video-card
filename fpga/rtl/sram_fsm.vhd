----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 22:27:43
-- Design Name: 
-- Module Name: sram_fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_fsm is
    port(
        i_clk      : in  std_logic;
        i_rst      : in  std_logic;
        i_data     : in  std_logic_vector(15 downto 0);
        i_write    : in  std_logic;
        o_ram_addr : out std_logic_vector(26 downto 0);
        o_ram_data : out std_logic_vector(15 downto 0);
        o_ram_lb   : out std_logic;
        o_ram_ub   : out std_logic;
        o_ram_cen  : out std_logic;
        o_ram_wen  : out std_logic
    );
end sram_fsm;

architecture Behavioral of sram_fsm is
    component bin_counter is
        generic(
            c_WIDTH : integer := 32
        );
        port(
            i_clk   : in  std_logic;
            i_rst   : in  std_logic;
            i_en    : in  std_logic;
            o_count : out unsigned(c_WIDTH downto 0)
        );
    end component bin_counter;

    type state_type is (t_IDLE, t_WAIT, t_PREPARE, t_WRITE, t_CLEANUP);
    signal state         : state_type            := t_IDLE;
    signal next_state    : state_type            := t_IDLE;
    signal addr          : unsigned(26 downto 0) := (others => '0');
    signal data          : std_logic_vector(15 downto 0);
    signal waiting       : std_logic             := '0';
    signal timeout       : std_logic             := '0';
    signal timeout_count : unsigned(13 downto 0);
    signal writing       : std_logic             := '0';
    signal write_count   : unsigned(4 downto 0);
begin
    state_storage : process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            state <= t_IDLE;
        elsif rising_edge(i_clk) then
            state <= next_state;
        end if;
    end process state_storage;

    state_transition_logic : process(state, i_write, write_count, timeout)
    begin
        case state is
            when t_IDLE =>
                if (i_write = '1') then
                    next_state <= t_WAIT;
                else
                    next_state <= t_IDLE;
                end if;
            when t_WAIT =>
                if (i_write = '1') then
                    next_state <= t_PREPARE;
                elsif (timeout = '1') then
                    next_state <= t_IDLE;
                else
                    next_state <= t_WAIT;
                end if;
            when t_PREPARE =>
                next_state <= t_WRITE;
            when t_WRITE =>
                 if (write_count >= 26) then
                    next_state <= t_CLEANUP;
                else
                    next_state <= t_WRITE;
                end if;
            when t_CLEANUP =>
                next_state <= t_WAIT;
        end case;
    end process state_transition_logic;

    output_logic : process(state, addr, data, i_data)
    begin
        case state is
            when t_WRITE =>
                o_ram_addr <= std_logic_vector(addr);
                o_ram_data <= data;
                o_ram_lb   <= '0';
                o_ram_ub   <= '0';
                o_ram_cen  <= '0';
                o_ram_wen  <= '0';
            when others =>
                o_ram_addr <= (others => '0');
                o_ram_data <= (others => '0');
                o_ram_lb   <= '1';
                o_ram_ub   <= '1';
                o_ram_cen  <= '1';
                o_ram_wen  <= '1';
        end case;

        case state is
            when t_IDLE =>
                addr    <= (others => '0');
                timeout <= '0';
                waiting <= '0';
            when t_PREPARE =>
                data    <= i_data;
                writing <= '1';
                waiting <= '0';
            when t_CLEANUP =>
                addr    <= addr + 1;
                writing <= '0';
                waiting <= '1';
            when others => null;
        end case;
    end process output_logic;

--    timers : process(write_count, timeout_count)
--    begin
--        if (write_count = 26) then
--            done_writing <= '1';
--        end if;
--        if (timeout_count = 10000) then -- wait for 100 us
--            timeout <= '1';
 --       end if;
--    end process timers;

    write_counter : bin_counter
        generic map(c_WIDTH => 4)
        port map(
            i_clk   => i_clk,
            i_rst   => i_rst or not writing,
            i_en    => writing,
            o_count => write_count
        );

    timeout_counter : bin_counter
        generic map(c_WIDTH => 13)
        port map(
            i_clk   => i_clk,
            i_rst   => not waiting,
            i_en    => waiting,
            o_count => timeout_count
        );

end Behavioral;
