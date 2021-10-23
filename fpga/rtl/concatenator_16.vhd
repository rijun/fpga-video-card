----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 22:27:43
-- Design Name: 
-- Module Name: concatenator_16 - Behavioral
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

architecture Behavioral of concatenator_16 is
    type state_type is (t_EMPTY, t_HALF_FULL, t_FULL);
    signal state      : state_type                    := t_EMPTY;
    signal next_state : state_type                    := t_EMPTY;
    signal r_data     : std_logic_vector(15 downto 0) := (others => '0');
begin
    state_storage : process(i_rst, i_load)
    begin
        if rising_edge(i_load) then
            state      <= next_state;
        end if;
        if (i_rst = '1') then
            state  <= t_EMPTY;
        end if;
    end process state_storage;

    state_transition_logic : process(state, i_data)
    begin
        case state is
            when t_EMPTY =>
                next_state          <= t_HALF_FULL;
                r_data(15 downto 8) <= i_data;
            when t_HALF_FULL =>
                next_state         <= t_FULL;
                r_data(7 downto 0) <= i_data;
            when t_FULL =>
                next_state          <= t_HALF_FULL;
                r_data(15 downto 8) <= i_data;
        end case;
    end process state_transition_logic;

    output_logic : process(state, r_data)
    begin
        case state is
            when t_FULL =>
                o_dv   <= '1';
                o_data <= r_data;
            when others =>
                o_dv   <= '0';
                o_data <= (others => '0');
        end case;
    end process output_logic;

end Behavioral;
