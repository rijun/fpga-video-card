----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 22:27:43
-- Design Name: 
-- Module Name: concatenator_16 - RTL
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

entity concatenator_16 is
    port(
        i_rst  : in  std_logic;
        i_load : in  std_logic;
        i_data : in  std_logic_vector(7 downto 0);
        o_dv   : out std_logic;
        o_data : out std_logic_vector(15 downto 0)
    );
end concatenator_16;

architecture RTL of concatenator_16 is
    signal r_ld_counter : unsigned(1 downto 0);
    signal r_data       : std_logic_vector(15 downto 0) := (others => '0');
begin
    o_dv   <= '1' when r_ld_counter = 2 else '0';
    o_data <= r_data;

    process(i_rst, i_load)
    begin
        if rising_edge(i_load) then
            case r_ld_counter is
                when "00" =>
                    r_data(15 downto 8) <= i_data;
                    r_ld_counter <= r_ld_counter + 1;
                when "01" =>
                    r_data(7 downto 0) <= i_data;
                    r_ld_counter <= r_ld_counter + 1;
                when "10" =>
                    r_data(15 downto 8) <= i_data;
                    r_ld_counter <= r_ld_counter - 1;
                when others =>
                    r_ld_counter <= (others => '0');
            end case;
        end if;
        if (i_rst = '1') then
            r_ld_counter <= (others => '0');
        end if;
    end process;
end RTL;
