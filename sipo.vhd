library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Paquete que incluye el Registro SIPO -------------
package sipo_pkg is
    component sipo is
        port (
        in_dato         : in std_logic;
        in_clk          : in std_logic;
        in_hab          : in std_logic;
        in_reset        : in std_logic;
        out_datos       : out std_logic_vector (31 downto 0)); 
    end component;
end package;

-- Declaración de la entidad ---------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sipo is
    port (
        in_dato         : in std_logic;
        in_clk          : in std_logic;
        in_hab          : in std_logic;
        in_reset        : in std_logic;
        out_datos       : out std_logic_vector (31 downto 0));
end sipo;

-- Arquitectura e Implementación del Registro SIPO ----------------
architecture solucion_registro of sipo is
    signal estado_actual, estado_sig : std_logic_vector (31 downto 0);
begin
    out_datos <= estado_actual;

    Logicaestado_siguiente: process(all)
        begin
            if in_hab = '1' then
                estado_sig <= in_dato & estado_actual(31 downto 1);
            else
                estado_sig <= estado_actual;
            end if;
        end process;

    Memoria: process(all)
        begin
            if in_reset = '1' then 
                estado_actual <= (others => '0');
            elsif rising_edge(in_clk) then 
                estado_actual <= estado_sig;
            end if;
        end process;
end solucion_registro;

