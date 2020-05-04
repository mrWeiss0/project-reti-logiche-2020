#!/usr/bin/env python3
"""Test generator for VHDL code

usege: python generate.py [SECTION...]

This script will generate data for testbenchs in VHDL
with the parameters in the ``generate.ini`` configuration file,
in which each section describes a testbench.
Tests are generated in a file with the name of its section.
Specific sections to be generated can be specified as arguments,
or by default all sections in the file are considered.

These parameters can be specified:

``path``            The path of the generated file

``seed``            String passed to random.seed()

``clock_period``    String in VHDL time format

``mem_delay``       .

``data_sz``         Size of the addresses used

``Dwz``             The working zone dimension

``Nwz``             The number of working zones

``address_count``   Number of addresses tested in each test

``generated_count`` Number of tests to randomly generate

``user_tests``      JSON formatted list of user defined test data.
                    each test is a dict containing ``wz_base``,
                    a list of working zone base addresses, and optionally
                    ``address_in``, a list of addresses to test.
                    If omitted, ``address_in`` is randomly generated.
                    Addresses can be integer or binary strings.
"""

import random
import logging
from sys import argv
from os import path, makedirs
from configparser import ConfigParser
from json import loads

CONF_FILE = 'generate.ini'

def main():
    config = ConfigParser(converters={"json":loads})
    with open(CONF_FILE, "r") as fconf:
        config.read_file(fconf)
    for sectname in argv[1:] or config.sections():
        logging.info(f"SECTION {sectname}")
        section = config[sectname]
        try:
            random.seed(section.get("seed"))
            data_sz       = int(section["data_sz"])
            Dwz           = int(section["Dwz"])
            address_count = int(section["address_count"])
            max_Nwz = 2**(data_sz - 1 - Dwz)
            Nwz           = section.getint("Nwz", max_Nwz)

            if Nwz > max_Nwz:
                raise ValueError(f"Nwz = {Nwz} exceedes maximum value {max_Nwz}")

            g = TestGenerator(data_sz, Dwz, Nwz, address_count)
            user_tests = section.getjson("user_tests", [])
            generated_count = section.getint("generated_count", 0)
            tests = list(g.mergedTests(user_tests, generated_count))

            filepath = path.normpath(section["path"])
            makedirs(filepath, exist_ok=True)
            filename = path.join(filepath, sectname + ".vhd")
            with open(filename, "w") as vhd:
                vhd.write(template.format(
                    clock_period = section["clock_period"],
                    mem_delay = section["mem_delay"],
                    data_sz = data_sz,
                    Dwz = Dwz,
                    Nwz = Nwz,
                    address_count = address_count,
                    reset_count = len(tests),
                    test_data = toVHDL(tests or (g.emptyTest(),), data_sz,
                        sep=lambda d:"\n         " if not d else " ")
                ))
            logging.info(f"Write to file {filename}")
        except (ValueError, KeyError, TypeError) as e:
            logging.warning(e)

template = """-- Testbench generated in python
library ieee;
use ieee.std_logic_1164.all;
use work.common.all;

package test_data is
    constant clock_period  : time     := {clock_period};
    constant mem_delay     : time     := {mem_delay};
    constant data_sz       : positive := {data_sz};
    constant Dwz           : positive := {Dwz};
    constant Nwz           : positive := {Nwz};
    constant address_count : natural  := {address_count};
    constant reset_count   : natural  := {reset_count};

    type wz_base_array is array (0 to Nwz - 1) of std_logic_vector(data_sz - 1 downto 0);
    type test_address_r is record
        address, expected  : std_logic_vector(data_sz - 1 downto 0);
    end record test_address_r;
    type test_address_array is array(0 to address_count - 1) of test_address_r;
    type test_r is record
        wz_base : wz_base_array;
        test_address : test_address_array;
    end record test_r;
    type test_array is array(1 to reset_count) of test_r;

    constant test_data : test_array :=
        {test_data};
end test_data;
"""

def toVHDL(o, data_sz, sep=lambda x:" ", depth=0):
    """Return the VHDL array representation for the given list of items
    
    ints are converted in the std_logic_vector representation with given size
    ``sep`` takes the depth level and returns the desidered separator
    """
    if isinstance(o, int):
        return f'"{o:0{data_sz}b}"'
    elif isinstance(o, (list,  tuple)):
        if not o:
            raise ValueError("Empty list")
        return ("(" + ("others => {}".format(toVHDL(o[0], data_sz, sep, depth + 1)) if len(o) == 1 else
            ("," + sep(depth)).join(toVHDL(i, data_sz, sep, depth + 1) for i in o)) + ")")
    elif isinstance(o, dict):
        if not o:
            raise ValueError("Empty dict")
        return ("(" + ("," + sep(depth)).join(
            "{} => {}".format(k, toVHDL(i, data_sz, sep, depth + 1)) for k, i in o.items()) + ")")
    else:
        raise TypeError("Unsupported type " + type(o))

def _ranks(sample):
    """Return the ranks of each element in an integer sample.

    ranks([10, 2, 4, 8, 6]) --> [4, 0, 1, 3, 2]
    """
    indices = sorted(range(len(sample)), key=lambda i: sample[i])
    return sorted(indices, key=lambda i: indices[i])

def _samplesRangeDist(n, k, d = 1):
    """Return samples of k elements from range(n), with a minimum distance d."""
    while True:
        sample = random.sample(range(n-(k-1)*(d-1)), k)
        yield [s + (d-1)*r for s, r in zip(sample, _ranks(sample))]

class TestGenerator:
    """This class builds tests, either randomly generated or from user data."""

    def __init__(self, data_sz, Dwz, Nwz, address_count):
        """Initialize an instance"""
        self.data_sz, self.Dwz, self.Nwz = data_sz, Dwz, Nwz
        self.address_count = address_count
        self.addressRange = 2**(self.data_sz - 1)
        self.wz_base_gen = _samplesRangeDist(2**(self.data_sz - 1) - self.Dwz + 1, self.Nwz, self.Dwz)

    def generatedTests(self, n):
        """Return n Test objects randomly generated"""
        for r in range(n):
            yield self._getTest(next(self.wz_base_gen), self._sampleAddress())

    def userTests(self, tests):
        """Return Test objects from the given test data"""
        for i, test in enumerate(tests):
            try:
                if len(test["wz_base"]) != self.Nwz:
                    raise ValueError("wz_base must have Nwz length")
                wz_base = [self._conv_addr(a) for a in test["wz_base"]]
                wz_base_sorted = sorted(wz_base)
                for w0, w1 in zip(wz_base_sorted, wz_base_sorted[1:]):
                    if w1 - w0 < self.Dwz:
                        raise ValueError("wz_base {w0} and {w1} overlap")
                if "address_in" not in test:
                    logging.info(f"User test {i}: Random addresses")
                    address_in = self._sampleAddress()
                elif len(test["address_in"]) != self.address_count:
                    raise ValueError("address_in must have address_count length")
                else:
                    address_in = [self._conv_addr(a) for a in test["address_in"]]
            except (ValueError, TypeError) as e:
                logging.warning(f"User test {i}: {e}")
            else:
                yield self._getTest(wz_base, address_in)
                
    def mergedTests(self, tests, n_gen):
        "Return Test objects from the ``tests`` data, then return ``n_gen`` generated tests"
        yield from self.userTests(tests)
        yield from self.generatedTests(n_gen)
    
    def emptyTest(self):
        "Return an empty test to format the VHDL output with a mock value"
        return {"wz_base" : (0,), "test_address" : ((0,0),)}

    def _conv_addr(self, addr):
        """Return the int value of addr, if it is a binary string,
        or addr itself if it is an int already"""
        if isinstance(addr, int):
            aval = addr
        elif isinstance(addr, str):
            aval = int(addr, 2)
        else:
            raise TypeError("Address must be a string or int")
        if aval >= self.addressRange:
            raise ValueError("Address out of range")
        return aval

    def _sampleAddress(self):
        """Return a sample of addresses from the valid range"""
        return random.sample(range(self.addressRange), self.address_count)

    def _results(self, wz_base, address_in):
        """Return pairs (address, expected result) for each tested address"""
        for address in address_in:
            for i, base in enumerate(wz_base):
                offset = address - base
                if offset in range(0, self.Dwz):
                    expected = ((1 << self.data_sz - 1) +
                            (i << self.Dwz) +
                            (1 << offset))
                    break
            else: expected = address
            yield (address, expected)

    def _getTest(self, wz_base, address_in):
        """Return a Test object from the given test data"""
        return {"wz_base" : wz_base, "test_address" : list(self._results(wz_base, address_in)) or ((0,0),)}

if __name__ == "__main__":
    logging.basicConfig(format="%(levelname)s: %(message)s", level=logging.INFO)
    main()
