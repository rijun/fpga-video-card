----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 22:27:43
-- Design Name: 
-- Module Name: sram_fsm - RTL
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

architecture RTL of sram_fsm is
    component counter_up is
        generic(
            c_WIDTH : integer := 4;
            c_MAX   : integer := 7
        );
        port(
            i_clk : in  std_logic;
            i_rst : in  std_logic;
            i_en  : in  std_logic;
            o_out : out std_logic
        );
    end component counter_up;

    type state_type is (t_IDLE, t_WAIT, t_WRITE);
    signal state      : state_type            := t_IDLE;
    signal addr       : unsigned(26 downto 0) := (others => '0');
    signal data       : std_logic_vector(15 downto 0);
    signal data_avail : std_logic;
    signal waiting    : std_logic;
    signal timeout    : std_logic;
    signal writing    : std_logic;
    signal write_done : std_logic;
begin
    o_ram_addr <= std_logic_vector(addr);
    
    state_machine : process(i_clk, i_rst)
    begin
        if rising_edge(i_clk) then
            o_ram_data <= (others => 'Z');
            o_ram_lb   <= 'Z';
            o_ram_ub   <= 'Z';
            o_ram_cen  <= 'Z';
            o_ram_wen  <= 'Z';

            case state is
                when t_IDLE =>
                    addr    <= (others => '0');
                    waiting <= '0';
                    writing <= '0';

                    if (data_avail = '1') then
                        state <= t_WAIT;
                    end if;
                when t_WAIT =>
                    writing <= '0';
                    waiting <= '1';

                    if (data_avail = '1') then
                        data    <= i_data;
                        writing <= '1';
                        waiting <= '0';
                        state   <= t_WRITE;
                    elsif (timeout = '1') then
                        state <= t_IDLE;
                    end if;
                when t_WRITE =>
                    o_ram_data <= data;
                    o_ram_lb   <= '0';
                    o_ram_ub   <= '0';
                    o_ram_cen  <= '0';
                    o_ram_wen  <= '0';

                    if (write_done = '1') then
                        addr  <= addr + 1;
                        state <= t_WAIT;
                    end if;
            end case;
        end if;

        if i_rst = '1' then
            state <= t_IDLE;
        end if;
    end process state_machine;

    start_transfer : process(i_write, writing, i_rst)
    begin
        if rising_edge(i_write) then
            data_avail <= '1';
        elsif rising_edge(writing) then
            data_avail <= '0';
        end if;
        if i_rst = '1' then
            data_avail <= '0';
        end if;
    end process start_transfer;

    write_counter : counter_up
        generic map(
            c_WIDTH => 5,
            c_MAX   => 26
        )
        port map(
            i_clk => i_clk,
            i_rst => i_rst or not writing,
            i_en  => writing,
            o_out => write_done
        );

    timeout_counter : counter_up
        generic map(
            c_WIDTH => 14,
            c_MAX   => 10000
        )
        port map(
            i_clk => i_clk,
            i_rst => i_rst or not waiting,
            i_en  => waiting,
            o_out => timeout
        );

end RTL;
