#!/usr/bin/env python3
import unittest
from rearrange import rearrange_name


class TestRearrange(unittest.TestCase):
    def test_basic(self):
        testCase = "Lovelace, Ada"
        expected = "Ada Lovelace"
        self.assertEqual(rearrange_name(testCase), expected)


    def test_empty(self):
        testCase = ""
        expected = ""
        self.assertEqual(rearrange_name(testCase), expected)


    def test_double_name(self):
        testCase = "Hopper, Grace M."
        expected = "Grace M. Hopper"
        self.assertEqual(rearrange_name(testCase), expected)


    def test_one_name(self):
        testCase = "Tina"
        expected = "Tina"
        self.assertEqual(rearrange_name(testCase), expected)


class TestStringMethods(unittest.TestCase):
    def testUpper(self):
        self.assertEqual('tina'.upper(), 'TINA')


    def testIsUpper(self):
        self.assertTrue('TINA'.isupper())
        self.assertFalse('Tina'.isupper())


    def testSplit(self):
        s = "Hello World"
        self.assertEqual(s.split(), ['Hello', 'World'])

        with self.assertRaises(TypeError):
            s.split(2)

if __name__ == "__main__":
    unittest.main()
