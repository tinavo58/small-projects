#!/usr/bin/env python3
from collections import Counter


def char_frequency(filename):
    # open file
    try:
        f = open(filename)
    except OSError:
        return None

    # process
    chars = Counter(char for line in f for char in line)

    # close file
    f.close()

    return chars


if __name__ == '__main__':
    result = char_frequency("/Users/tina.myvo/Desktop/coding/Python/local-repo/small-projects/coursera/unittests/output/copied_test_file.txt")
    print(result)
