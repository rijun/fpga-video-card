----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2021 14:37:36
-- Design Name: 
-- Module Name: vga_counter - RTL
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

entity vga_counter is
    port(i_clk       : in  std_logic;
         i_resetn    : in  std_logic;
         o_h_count : out std_logic_vector(9 downto 0);
         o_v_count : out std_logic_vector(9 downto 0));
end vga_counter;

architecture RTL of vga_counter is
    signal clk       : std_logic;
    signal rst       : std_logic;
    signal h_counter : unsigned(9 downto 0);
    signal v_counter : unsigned(9 downto 0);
begin
    clk       <= i_clk;
    rst       <= not i_resetn;
    o_h_count <= std_logic_vector(h_counter);
    o_v_count <= std_logic_vector(v_counter);

    counter_proc : process(clk, rst)
    begin
        if (rst = '1') then
            h_counter <= (others => '0');
            v_counter <= (others => '0');
        elsif (rising_edge(clk)) then
            if (h_counter = 799) then
                v_counter <= v_counter + 1;
                h_counter <= (others => '0');
            else
                h_counter <= h_counter + 1;
            end if;

            if (v_counter = 520) then
                v_counter <= (others => '0');
            end if;
        end if;
    end process;
end RTL;
