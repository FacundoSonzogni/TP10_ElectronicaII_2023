library IEEE;
use IEEE.std_logic_1164.all;
use std.env.finish;

entity receptor_ir_tb is
    -- Vacío
end receptor_ir_tb;

architecture tb of receptor_ir_tb is
    -- Declaraciones
    component receptor_ir is
        port (
            rst        : in std_logic;
            infrarrojo : in std_logic;
            hab        : in std_logic;
            clk        : in std_logic;
            valido     : out std_logic;
            dir        : out std_logic_vector (7 downto 0);
            cmd        : out std_logic_vector (7 downto 0));
    end component;

    signal in_rst         : std_logic;
    signal in_infrarrojo  : std_logic;
    signal in_hab         : std_logic;
    signal in_clk         : std_logic;
    signal out_valido     : std_logic;
    signal out_dir        : std_logic_vector (7 downto 0);
    signal out_cmd        : std_logic_vector (7 downto 0);
    constant MEDIO_CICLO : time      := 187.5 us / 2;

begin
    -- Implementación
    DUT : receptor_ir port map (
        rst        => in_rst,
        infrarrojo => in_infrarrojo,
        hab        => in_hab,
        clk        => in_clk,
        valido     => out_valido,
        dir        => out_dir,
        cmd        => out_cmd);
    
    -- lazo infinito
    reloj    : process
    begin
        in_clk <= '0';
        wait for MEDIO_CICLO;
        in_clk <= '1';
        wait for MEDIO_CICLO;
    end process;

    estimulo : process
        -- Infrarrojo
        constant SIN_LUZ     : std_logic := '1';
        constant CON_LUZ     : std_logic := '0';
        
        constant TIEMPO_LUZ_START : time := 9 ms;
        constant TIEMPO_OSC_START : time := 4.5 ms;
        constant TIEMPO_OSC_REP   : time := TIEMPO_OSC_START/2;
        constant TIEMPO_LUZ_BIT   : time := 562.5 us;
        constant TIEMPO_OSC_CERO  : time := 1 * TIEMPO_LUZ_BIT;
        constant TIEMPO_OSC_UNO   : time := 3 * TIEMPO_LUZ_BIT;
        constant TIEMPO_LUZ_STOP  : time := TIEMPO_LUZ_BIT;
        constant DIR_1 : std_logic_vector (7 downto 0) := x"EF";
        constant CMD_1 : std_logic_vector (7 downto 0) := x"AD";
        constant DIR_2 : std_logic_vector (7 downto 0) := x"AA";
        constant CMD_2 : std_logic_vector (7 downto 0) := x"BB";
    begin
        in_rst        <= '1';
        in_hab        <= '1';
        in_infrarrojo <= SIN_LUZ;
        wait for MEDIO_CICLO/2;
        in_rst        <= '0';
        wait for 1 ns;
        wait on in_clk until in_clk='0'; -- sincronizo con reloj
        wait for MEDIO_CICLO/2; -- a mitad del semiciclo
        
        -- inicio
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_START;
        in_infrarrojo <= SIN_LUZ;
        wait for TIEMPO_OSC_START;
        for invertir in 0 to 1 loop
            for i in DIR_1'REVERSE_RANGE loop
                in_infrarrojo <= CON_LUZ;
                wait for TIEMPO_LUZ_BIT;
                in_infrarrojo <= SIN_LUZ;
                if    (invertir = 0 and DIR_1(i) = '1') 
                   or (invertir = 1 and DIR_1(i) = '0') then
                    wait for TIEMPO_OSC_UNO;
                else
                    wait for TIEMPO_OSC_CERO;
                end if;
            end loop;
        end loop;
        for invertir in 0 to 1 loop
            for i in CMD_1'REVERSE_RANGE loop
                in_infrarrojo <= CON_LUZ;
                wait for TIEMPO_LUZ_BIT;
                in_infrarrojo <= SIN_LUZ;
                if    (invertir = 0 and CMD_1(i) = '1') 
                   or (invertir = 1 and CMD_1(i) = '0') then
                    wait for TIEMPO_OSC_UNO;
                else
                    wait for TIEMPO_OSC_CERO;
                end if;
            end loop;    
        end loop;
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_STOP;
        in_infrarrojo <= SIN_LUZ;
        
        -- Repeticion------------------------
        wait for 10 ms;
        in_hab        <= '0';
        wait for 10 ms;
        in_hab        <= '1';
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_START;
        in_infrarrojo <= SIN_LUZ;
        wait for TIEMPO_OSC_REP;
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_STOP;
        in_infrarrojo <= SIN_LUZ;
        wait for 1 ms;

        -- Envia otro codigo------------------
        wait for 10 ms;
        in_hab        <= '0';
        wait for 10 ms;
        in_hab        <= '1';
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_START;
        in_infrarrojo <= SIN_LUZ;
        wait for TIEMPO_OSC_START;
        for invertir in 0 to 1 loop
            for i in DIR_2'REVERSE_RANGE loop
                in_infrarrojo <= CON_LUZ;
                wait for TIEMPO_LUZ_BIT;
                in_infrarrojo <= SIN_LUZ;
                if    (invertir = 0 and DIR_2(i) = '1') 
                   or (invertir = 1 and DIR_2(i) = '0') then
                    wait for TIEMPO_OSC_UNO;
                else
                    wait for TIEMPO_OSC_CERO;
                end if;
            end loop;
        end loop;
        for invertir in 0 to 1 loop
            for i in CMD_2'REVERSE_RANGE loop
                in_infrarrojo <= CON_LUZ;
                wait for TIEMPO_LUZ_BIT;
                in_infrarrojo <= SIN_LUZ;
                if    (invertir = 0 and CMD_2(i) = '1') 
                   or (invertir = 1 and CMD_2(i) = '0') then
                    wait for TIEMPO_OSC_UNO;
                else
                    wait for TIEMPO_OSC_CERO;
                end if;
            end loop;    
        end loop;
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_STOP;
        in_infrarrojo <= SIN_LUZ;
        wait for 1 ms;

        --Envia codigo invalido---------
        wait for 10 ms;
        in_hab        <= '0';
        wait for 10 ms;
        in_hab        <= '1';
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_START;
        in_infrarrojo <= SIN_LUZ;
        wait for TIEMPO_OSC_START;
        --Envia Dir_1
        for i in DIR_1'REVERSE_RANGE loop
            in_infrarrojo <= CON_LUZ;
            wait for TIEMPO_LUZ_BIT;
            in_infrarrojo <= SIN_LUZ;
            if  DIR_1(i) = '1' then 
                wait for TIEMPO_OSC_UNO;
            else
                wait for TIEMPO_OSC_CERO;
            end if;
        end loop;
        --Envia Dir_2
        for i in DIR_2'REVERSE_RANGE loop
            in_infrarrojo <= CON_LUZ;
            wait for TIEMPO_LUZ_BIT;
            in_infrarrojo <= SIN_LUZ;
            if  DIR_2(i) = '1' then
                wait for TIEMPO_OSC_UNO;
            else
                wait for TIEMPO_OSC_CERO;
            end if;
        end loop;
        
        for invertir in 0 to 1 loop
            for i in CMD_1'REVERSE_RANGE loop
                in_infrarrojo <= CON_LUZ;
                wait for TIEMPO_LUZ_BIT;
                in_infrarrojo <= SIN_LUZ;
                if    (invertir = 0 and CMD_1(i) = '1') 
                   or (invertir = 1 and CMD_1(i) = '0') then
                    wait for TIEMPO_OSC_UNO;
                else
                    wait for TIEMPO_OSC_CERO;
                end if;
            end loop;    
        end loop;
        in_infrarrojo <= CON_LUZ;
        wait for TIEMPO_LUZ_STOP;
        in_infrarrojo <= SIN_LUZ;
        wait for 20 ms;
        in_hab        <= '0';
        wait for 1 ms;

        finish;
    end process;




    
end architecture;