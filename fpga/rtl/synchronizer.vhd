----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2021 14:37:36
-- Design Name: 
-- Module Name: synchronizer - Behavioral
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

entity synchronizer is
    port(i_clk     : in  std_logic;
         i_rst     : in  std_logic;
         i_h_count : in  std_logic_vector(9 downto 0);
         i_v_count : in  std_logic_vector(9 downto 0);
         o_h_sync  : out std_logic;
         o_v_sync  : out std_logic;
         o_beam    : out std_logic;
         o_pixel_x : out std_logic_vector(9 downto 0);
         o_pixel_y : out std_logic_vector(8 downto 0));
end synchronizer;

architecture Behavioral of synchronizer is
    signal clk     : std_logic;
    signal rst     : std_logic;
    signal h_count : unsigned;
    signal v_count : unsigned;
begin
    clk     <= i_clk;
    rst     <= i_rst;
    h_count <= unsigned(i_h_count);
    v_count <= unsigned(i_v_count);

    sync_proc : process(clk, rst)
    begin
        if (rst = '1') then
            o_h_sync <= '0';
            o_v_sync <= '0';
        elsif (rising_edge(clk)) then
            if h_count <= 95 then
                o_h_sync <= '0';
            else
                o_h_sync <= '1';
            end if;

            if v_count <= 2 then
                o_v_sync <= '0';
            else
                o_v_sync <= '1';
            end if;
        end if;
    end process;

    pixel_proc : process(clk, rst)
    begin
        if (rst = '1') then
            o_beam    <= '0';
            o_pixel_x <= (others => '0');
            o_pixel_y <= (others => '0');
        elsif (rising_edge(clk)) then
            if (h_count >= 144 and h_count <= 783 and v_count >= 31 and v_count <= 510) then
                o_beam    <= '1';
                o_pixel_x <= std_logic_vector(h_count - 144);
                o_pixel_y <= std_logic_vector(v_count(8 downto 0) - 31);
            else
                o_beam    <= '0';
                o_pixel_x <= (others => '0');
                o_pixel_y <= (others => '0');
            end if;
        end if;
    end process;
end Behavioral;
