#!/usr/bin/env python3
import unittest


class Library:
    def __init__(self) -> None:
        self.collection = []


    def addBook(self, bookTitle: str) -> None:
        self.collection.append(bookTitle)


    def hasBook(self, bookTitle: str):
        return bookTitle in self.collection # return True/False


class TestLibrary(unittest.TestCase):
    lib = Library()
    lib.addBook("Maybe Not")

    def test_add_book_to_lib(self):
        self.assertEqual(self.lib.collection, ['Maybe Not'])


    def test_has_book(self):
        self.assertTrue(TestLibrary.lib.hasBook("Maybe Not"), True)


if __name__ == '__main__':
    unittest.main()
