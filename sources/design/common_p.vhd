package common is
    function log_Nwz(log_Dwz : natural; data_sz : positive) return natural;
end common;

package body common is
    function log_Nwz(log_Dwz : natural; data_sz : positive) return natural is
        begin
            return data_sz - 1 - 2 ** log_Dwz;
    end function;
end common;
