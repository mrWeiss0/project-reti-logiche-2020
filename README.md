Progetto finale di Reti Logiche
===============================
**Politecnico di Milano 2020**

The project consists in developing a hardware component in VHDL implementing the Working Zone encoding of the provided addresses. The component interfaces with a memory from which it reads input data and where it writes the result of the conversion.

## Documentation :it:
The documentation for the project is available on GitHub Pages at
[mrweiss0.github.io/project-reti-logiche-2020](https://mrweiss0.github.io/project-reti-logiche-2020/)

Print to PDF with [Prince](https://www.princexml.com)
```
prince --javascript --no-artificial-fonts index.html
```
Or print in browser, but with less features (no page numbers).

## Tests
Tests are implemented in `test_p.vhd` in [test sources](sources/test)
with three procedures common for every testbench.

The data for each test are in a separated file
generated running the script [`test.py`](test.py)
with the configuration in [`test.ini`](test.ini).
Each section in the configuration generates a test with the given parameters,
values can be manually inserted or randomly generated.  
Configuration parameters are explained in `test.py`.

## How to regenerate Vivado Project after cloning
Generate test data
```
python3 generate.py
```

Get vivado-git submodule
```
git submodule init
git submodule update
```
Regenerate project with vivado-git
```
python2 vivado-git/checkout.py
```

Vivado project is at `workspace/project_reti_logiche/project_reti_logiche.vhd`

## Project specification
This is the assigned specification for the project:

[Project specification](specs/README.md) :it:

[Original PDF version](specs/PFRL_Specifica_1920.pdf) :it:

[Reference article](specs/Musoll-Lang-Cortadella.pdf) :uk: E. Musoll, T. Lang and J. Cortadella, "Working-zone encoding for reducing the energy in microprocessor address buses", in *IEEE Transactions on Very Large Scale Integration (VLSI) Systems*, vol. 6, no. 4, pp. 568-572, Dec. 1998
