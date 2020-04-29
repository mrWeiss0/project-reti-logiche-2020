package common is
    -- Return the log2 of the number of working zones
    -- given the log2 of their dimension and the size of addresses
    function log_Nwz(log_Dwz : natural; data_sz : positive) return natural;
     
    function max(a : integer; b : integer) return integer;
end common;

package body common is
    function log_Nwz(log_Dwz : natural; data_sz : positive) return natural is
        begin
            return data_sz - 1 - 2 ** log_Dwz;
    end function;
    function max(a : integer; b : integer) return integer is
        begin
            if a > b then
                return a;
            end if;
            return b;
    end function;
end common;
