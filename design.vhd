library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_16bits_pkg.all;
use work.control_pkg.all;
use work.sipo_pkg.all;
use work.det_tiempo_pkg.all;

-- Paquete que incluye el Receptor de Infrarrojo -------------
package receptor_ir_pkg is
    component receptor_ir is
        port (
        rst          : in std_logic;
        infrarrojo   : in std_logic;
        hab          : in std_logic;
        clk          : in std_logic;
        valido       : out std_logic;
        dir          : out std_logic_vector (7 downto 0);
        cmd          : out std_logic_vector (7 downto 0)); 
    end component;
end package;

-- Declaración de la entidad ---------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_16bits_pkg.all;
use work.control_pkg.all;
use work.sipo_pkg.all;
use work.det_tiempo_pkg.all;

entity receptor_ir is
    port (
        rst          : in std_logic;
        infrarrojo   : in std_logic;
        hab          : in std_logic;
        clk          : in std_logic;
        valido       : out std_logic;
        dir          : out std_logic_vector (7 downto 0);
        cmd          : out std_logic_vector (7 downto 0));
end receptor_ir;

-- Arquitectura e Implementación del Receptor de Infrarrojo ----------------
architecture arch of receptor_ir is

    -- Declaración de Componentes 
    component ffd_16bits
        port(
            in_cmd          : in std_logic_vector (7 downto 0);
            in_dir          : in std_logic_vector (7 downto 0);
            in_hab          : in std_logic;
            in_reset        : in std_logic;
            in_clk          : in std_logic;
            out_cmd         : out std_logic_vector (7 downto 0);
            out_dir         : out std_logic_vector (7 downto 0));
    end component;

    component sipo
        port (
            in_dato         : in std_logic;
            in_clk          : in std_logic;
            in_hab          : in std_logic;
            in_reset        : in std_logic;
            out_datos       : out std_logic_vector (31 downto 0));
    end component;

    component det_tiempo
        port (
            rst     : in std_logic;
            pulso   : in std_logic;
            hab     : in std_logic;
            clk     : in std_logic;
            med     : out std_logic;
            tiempo  : out std_logic_vector (5 downto 0));
    end component;

    component control
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

    -- Declaración de Señales
    signal mensaje_correcto, med_det, desplazar, habilitar_ff : std_logic;
    signal tiempo_det : std_logic_vector (5 downto 0);
    signal dato_entrada, dato_salida : std_logic_vector (31 downto 0);
    signal cmd_sig, cmd_negado_sig, cmd_act, dir_sig, dir_negado_sig, dir_act : std_logic_vector (7 downto 0);

    -- Implementación del Receptor  
begin

Detector_Tiempo_Pulsos: det_tiempo port map (
    rst      => rst,
    pulso    => not infrarrojo,
    hab      => hab,
    clk      => clk,
    med      => med_det,
    tiempo   => tiempo_det
);

Control: control port map (
    hab           => hab,
    med           => med_det,
    rst           => rst,
    clk           => clk,
    mensaje_ok    => mensaje_correcto,
    tiempo        => tiempo_det,
    valido        => valido,
    dato          => dato_entrada,
    hab_FF        => habilitar_ff,
    hab_sipo      => desplazar
);

Registro_Desplazamiento: sipo port map (
    in_dato          => dato_entrada,
    in_clk           => clk,
    in_hab           => desplazar,
    in_reset         => rst,
    out_datos        => dato_salida
);

cmd_negado_sig <= dato_salida (31 downto 24);
cmd_sig        <= dato_salida (23 downto 16);
dir_negado_sig <= dato_salida (15 downto 8);
dir_sig        <= dato_salida (7 downto 0); 

mensaje_correcto <= '1' when ((cmd_negado_sig = not cmd_sig)  and  (dir_negado_sig = not dir_sig)) else
                    '0';

Flip_Flop_16bits: ffd_16bits port map (
    in_cmd       => cmd_sig,
    in_dir       => dir_sig,
    in_hab       => habilitar_ff,
    in_reset     => rst,
    in_clk       => clk,
    out_cmd      => cmd_act,  
    out_dir      => dir_act   
);

cmd <= cmd_act;
dir <= dir_act;
    
end architecture;




