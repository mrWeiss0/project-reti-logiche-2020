package common is
    function log2(n : positive) return natural;
end common;

package body common is
    function log2(n : positive) return natural is
        variable l : natural := 0;
        
        begin
            while 2**l < n loop
                l := l + 1;
            end loop;
            return l;
    end function;
end common;
