#!/usr/bin/env python3
import os
import shutil
import unittest

# func to test
def simpleAddition(a, b):
    return a + b

# paths for file ops
ORIGINAL_FILE_PATH = "./output/original_test_file.txt"
COPIED_FILE_PATH = "./output/copied_test_file.txt"

# global counter
COUNTER = 0

# run once before test/test class
def setUpModule():
    global COUNTER
    COUNTER = 0

    with open(ORIGINAL_FILE_PATH, 'w') as file:
        file.write("Test Results:\n")

# run once after tests executed
def tearDownModule():
    shutil.copy2(ORIGINAL_FILE_PATH, COPIED_FILE_PATH)

    os.remove(ORIGINAL_FILE_PATH)


class TestSimpleAddition(unittest.TestCase):

    # this will run before each individual test
    def setUp(self) -> None:
        global COUNTER
        COUNTER += 1

    # this will run after each test
    def tearDown(self) -> None:
        with open(ORIGINAL_FILE_PATH, 'a') as file:
            result = "PASSED" if self._outcome.success else "FAILED"
            file.write(f"Test {COUNTER}: {result}\n")

    def testAddPositiveNumbers(self):
        self.assertEqual(simpleAddition(3, 4), 7)

    def testAddNegativeNumbers(self):
        self.assertEqual(simpleAddition(-3, -4), -7)


if __name__ == '__main__':
    unittest.main()

    with open(COPIED_FILE_PATH) as result_file:
        print(result_file.read())
