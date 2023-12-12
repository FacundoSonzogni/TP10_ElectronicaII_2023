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
    signal dato_act, dato_sig : std_logic_vector (31 downto 0);
    signal cont_sig, cont_act : std_logic_vector (5 downto 0);
begin

    MEMORIA_ESTADO : process (clk, rst)
    begin
        if rst = '1' then     -- Si rst = '1', debe mantenerse en estado de "Espera"
            hab_FF <= '0';
            hab_sipo <= '0';
            valido <= '0';
            dato_act <= (others => '0');
            cont_act <= (others => '0');
        elsif rising_edge(clk) then
            if hab = '1' then   -- Cuando hab = '1', funciona normalmente, caso contrario, todo mantiene su valor
                dato_act <= dato_sig;
                cont_act <= cont_sig;
            end if;
        end if;
    end process;

    LOGICA_ESTADO_SIGUIENTE : process (all)
    begin
        if  med = '0' then    -- Si med = '0' se encuentra en "Espera" y debe mantenerse hasta que med sea 1 
            hab_FF <= '0';
            hab_sipo <= '0';
            valido <= '0';
            dato_act <= (others => '0');
            cont_act <= (others => '0');
        elsif med = '1' then   -- Si med = '1' terminó la medición. Debe pasar al estado de "Recepción"

            ------------------------------TERMINAR-------------------------------------------------------

        end if;
    end process;
   
end architecture;