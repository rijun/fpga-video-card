----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2021 14:37:36
-- Design Name: 
-- Module Name: vga_synchronizer - RTL
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

entity vga_synchronizer is
    port(i_clk        : in  std_logic;
         i_rst        : in  std_logic;
         i_horz_count : in  std_logic_vector(9 downto 0);
         i_vert_count : in  std_logic_vector(9 downto 0);
         o_h_sync     : out std_logic;
         o_v_sync     : out std_logic);
end vga_synchronizer;

architecture RTL of vga_synchronizer is
    signal w_h_count : unsigned;
    signal w_v_count : unsigned;
begin
    w_h_count <= unsigned(i_horz_count);
    w_v_count <= unsigned(i_vert_count);

    sync_proc : process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_h_sync <= '0';
            o_v_sync <= '0';
        elsif (rising_edge(i_clk)) then
            if w_h_count <= 95 then
                o_h_sync <= '0';
            else
                o_h_sync <= '1';
            end if;

            if w_v_count <= 2 then
                o_v_sync <= '0';
            else
                o_v_sync <= '1';
            end if;
        end if;
    end process;
end RTL;
