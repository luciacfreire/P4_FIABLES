library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sma_filter is
    generic (
        N     : integer := 4;
        WIDTH : integer := 8
    );
    port (
        clk  : in std_logic;
        rst  : in std_logic;
        din  : in std_logic_vector(WIDTH-1 downto 0);
        load : in std_logic;
        dout : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture rtl of sma_filter is
    type sample_array is array(0 to N-1) of unsigned(WIDTH-1 downto 0);
    signal samples : sample_array := (others => (others => '0'));
    signal sum     : unsigned(WIDTH+1 downto 0) := (others => '0'); -- enough width for sum
    signal avg     : unsigned(WIDTH-1 downto 0);
begin

    process(clk, rst)
        variable temp_samples : sample_array;
        variable temp_sum     : unsigned(WIDTH+1 downto 0);
    begin
        if rst = '1' then
            samples <= (others => (others => '0'));
            sum     <= (others => '0');
            avg     <= (others => '0');
        elsif rising_edge(clk) then
            temp_samples := samples;
            temp_sum := sum;

            if load = '1' then
                -- resta la muestra más antigua
                temp_sum := temp_sum - resize(temp_samples(N-1), temp_sum'length);

                -- desplaza las muestras
                for i in N-1 downto 1 loop
                    temp_samples(i) := temp_samples(i-1);
                end loop;
                temp_samples(0) := unsigned(din);

                -- añade la nueva muestra
                temp_sum := temp_sum + resize(unsigned(din), temp_sum'length);

                -- actualiza señales
                samples <= temp_samples;
                sum     <= temp_sum;
            end if;

            avg <= resize(temp_sum / to_unsigned(N, temp_sum'length), avg'length);
        end if;
    end process;

    dout <= std_logic_vector(avg);

end architecture;