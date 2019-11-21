library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity deslocador2 is 
    port(
          dataIn :in std_logic_vector(25 downto 0);
          dataOut :out std_logic_vector(27 downto 0)
        );
end entity;

architecture behavior of deslocador2 is
  begin
    process(dataIn) 
      begin 
        dataOut(27 downto 2) <= dataIn(25 downto 0) ;
        dataOut(1 downto 0) <= "00";
    end process;

end architecture;