----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.10.2021 10:12:52
-- Design Name: 
-- Module Name: counter_up - RTL
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

entity counter_up is
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
end entity counter_up;

architecture RTL of counter_up is
    signal r_counter : unsigned(c_WIDTH - 1 downto 0);
begin
    process(i_rst, i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_en = '1') then
                if (r_counter < c_MAX) then
                    r_counter <= r_counter + 1;
                else
                    o_out <= '1';
                end if;
            end if;
        end if;
        if (i_rst = '1') then
            r_counter <= (others => '0');
            o_out     <= '0';
        end if;
    end process;
end architecture RTL;
