----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.10.2021 10:20:52
-- Design Name: 
-- Module Name: tb_counter_up - Behavioral
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
use std.env.finish;

entity tb_counter_up is
end entity tb_counter_up;

architecture Behavioral of tb_counter_up is
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
    end component;

    signal tb_clk : std_logic := '0';
    signal tb_rst : std_logic := '0';
    signal tb_en  : std_logic := '0';
    signal tb_out : std_logic;

    procedure wait_clk(constant cycle : in integer) is
    begin
        for i in 0 to cycle - 1 loop
            wait until falling_edge(tb_clk);
        end loop;
    end procedure;
begin
    -- Clock generation @ 100 MHz
    tb_clk <= not tb_clk after 5 ns;

    DUT : counter_up
        generic map(
            c_WIDTH => 13,
            c_MAX   => 1000
        )
        port map(
            i_clk => tb_clk,
            i_rst => tb_rst,
            i_en  => tb_en,
            o_out => tb_out
        );

    test_counter_up : process
    begin
        -- Reset system
        tb_rst        <= '1';
        wait_clk(10);
        tb_rst        <= '0';
        wait_clk(10);
        tb_en <= '1';
        wait_clk(1100);
        -- Stop simulation
        report "Simulation completed";
        finish;
    end process;
end architecture Behavioral;
