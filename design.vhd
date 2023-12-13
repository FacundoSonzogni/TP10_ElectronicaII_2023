-- Declaración de la entidad ---------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.componentes_pkg.all;

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

    -- Declaración de Señales
    signal mensaje_correcto, med_det, desplazar, habilitar_ff : std_logic;
    signal tiempo_det   : std_logic_vector (4 downto 0);
    signal dato_entrada : std_logic;
    signal dato_salida  : std_logic_vector (31 downto 0);
    signal cmd_sig, cmd_negado_sig, cmd_act, dir_sig, dir_negado_sig, dir_act : std_logic_vector (7 downto 0);

    -- Implementación del Receptor  
begin

Memoria: process (clk,rst)
begin
    if rst = '1' then
        cmd_act <= (others => '0');
        dir_act <= (others => '0');
    elsif rising_edge(clk) and habilitar_ff = '1' then
        cmd_act <= cmd_sig;
        dir_act <= dir_sig;
    end if;
end process;

Detector_Tiempo_Pulsos: det_tiempo generic map (N => 5) port map (
    rst      => rst,
    pulso    => not infrarrojo,
    hab      => hab,
    clk      => clk,
    med      => med_det,
    tiempo   => tiempo_det
);

control_1: control port map (
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

Registro_Desplazamiento: sipo generic map (N => 32) port map (
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


cmd <= cmd_act;
dir <= dir_act;
    
end architecture;




