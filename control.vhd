library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_16bits_pkg.all;
use work.control_pkg.all;
use work.sipo_pkg.all;
use work.det_tiempo_pkg.all;
use work.receptor_ir_pkg.all;

-- Paquete que incluye el Controlador -------------
package control_pkg is
    component control is
        port (
            hab          : in std_logic;
            med          : in std_logic;
            rst          : in std_logic;
            clk          : in std_logic;
            mensaje_ok   : in std_logic;
            tiempo       : in std_logic_vector (5 downto 0);
            valido       : out std_logic;
            dato         : out std_logic_vector (31 downto 0); -- Cuanto vale N?
            hab_FF       : out std_logic;
            hab_sipo     : out std_logic);
    end component;
end package;

-- Declaración de la entidad ---------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_16bits_pkg.all;
use work.control_pkg.all;
use work.sipo_pkg.all;
use work.det_tiempo_pkg.all;
use work.receptor_ir_pkg.all;

entity control is
    port (
            hab          : in std_logic;
            med          : in std_logic;
            rst          : in std_logic;
            clk          : in std_logic;
            mensaje_ok   : in std_logic;
            tiempo       : in std_logic_vector (5 downto 0);
            valido       : out std_logic;
            dato         : out std_logic_vector (31 downto 0); -- Cuanto vale N?
            hab_FF       : out std_logic;
            hab_sipo     : out std_logic);
end control;

-- Arquitectura e Implementación del Controlador ----------------
architecture solucion_control of control is
begin
   
end architecture;