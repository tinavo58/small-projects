#!/usr/bin/env python3
import unittest


def validateUser(username, minlen):
    assert type(username) == str, "username must be a string"

    if minlen < 1: raise ValueError("minlen must be at least 1")
    if len(username) < minlen: return False
    if not username.isalnum(): return False

    return True


class TestValidateUser(unittest.TestCase):

    def test_minlen_less_than_one(self):
        with self.assertRaises(ValueError):
            validateUser("tina", 0)


    def test_username_less_than_minlen(self):
        self.assertTrue(validateUser("tina", 3))


    def test_isalnum_part(self):
        self.assertFalse(validateUser("tina$%$", 10)) # False
        self.assertTrue(validateUser("123456", 3)) # True


    def test_empty_username(self):
        self.assertFalse(validateUser("", 1))


    def test_empty_list(self):
        # without using context manager
        self.assertRaises(AssertionError, validateUser, [], 1) # msg can't be called


    def test_empty_list(self):
        with self.assertRaises(AssertionError, msg="username must be a string"):
            self.assertFalse(validateUser(["tina"], 1))


if __name__ == '__main__':
    unittest.main()
