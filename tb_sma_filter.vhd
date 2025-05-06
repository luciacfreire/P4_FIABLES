library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sma_filter is
end entity;

architecture sim of tb_sma_filter is
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal din   : std_logic_vector(7 downto 0) := (others => '0');
    signal load  : std_logic := '0';
    signal dout  : std_logic_vector(7 downto 0);
begin

    -- Reloj 50 MHz
    clk_proc: process
    begin
        wait for 10 ns;
        clk <= not clk;
    end process;

    -- Instancia del filtro
    UUT: entity work.sma_filter
        generic map (
            N     => 4,
            WIDTH => 8
        )
        port map (
            clk  => clk,
            rst  => rst,
            din  => din,
            load => load,
            dout => dout
        );

    -- Estímulo
    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for 25 ns;
        rst <= '0';
        wait for 20 ns;

        -----------------------------------------------------------------
        -- 1) Triangular (8 muestras): 0→64→128→192→255→192→128→64
        -----------------------------------------------------------------
        for i in 0 to 4 loop
            for j in 0 to 7 loop
                case j is
                    when 0 => din <= x"00";
                    when 1 => din <= x"40";
                    when 2 => din <= x"80";
                    when 3 => din <= x"C0";
                    when 4 => din <= x"FF";
                    when 5 => din <= x"C0";
                    when 6 => din <= x"80";
                    when 7 => din <= x"40";
                    when others => null;
                end case;
                load <= '1';
                wait until rising_edge(clk);
                load <= '0';
                wait until rising_edge(clk);
            end loop;
        end loop;
        
        
        -- deja que el filtro procese
        for i in 0 to 10 loop
            din <= x"00";
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
        end loop;

        wait for 200 ns;  

        -----------------------------------------------------------------
        -- 2) Cuadrada (8 muestras): 255×4, luego 0×4
        -----------------------------------------------------------------
        for i in 0 to 7 loop
            if i < 4 then
                din <= x"FF";
            else
                din <= x"00";
            end if;
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
            wait until rising_edge(clk);
        end loop;

        -- deja que el filtro procese
        for i in 0 to 10 loop
            din <= x"00";
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
        end loop;

        wait for 200 ns;  


        -----------------------------------------------------------------
        -- 3) Diente de sierra (8 muestras): 0,32,64,96,128,160,192,255
        -----------------------------------------------------------------
        for i in 0 to 7 loop
            din <= std_logic_vector(to_unsigned(i*32, 8));
            if i = 7 then din <= x"FF"; end if;
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
            wait until rising_edge(clk);
        end loop;
        for i in 0 to 7 loop
            din <= std_logic_vector(to_unsigned(i*32, 8));
            if i = 7 then din <= x"FF"; end if;
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
            wait until rising_edge(clk);
        end loop;
        for i in 0 to 7 loop
            din <= std_logic_vector(to_unsigned(i*32, 8));
            if i = 7 then din <= x"FF"; end if;
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
            wait until rising_edge(clk);
        end loop;

        -- deja que el filtro procese
        for i in 0 to 10 loop
            din <= x"00";
            load <= '1';
            wait until rising_edge(clk);
            load <= '0';
        end loop;

        wait;  -- fin de simulación
    end process;

end architecture;
