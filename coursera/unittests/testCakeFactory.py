import unittest
from cakeFactory import CakeFactory


class TestCakeFactory(unittest.TestCase):
    def testCreateCake(self):
        cake = CakeFactory("vanilla", "small")

        self.assertEqual(cake.cakeType, "vanilla")
        self.assertEqual(cake.size, "small")
        self.assertEqual(cake.price, 8)


    def testAddToppings(self):
        cake = CakeFactory("chocolate", "large")
        cake.addTopping("sprinkles")

        self.assertIn("sprinkles", cake.toppings)


    def testCheckIngredients(self):
        cake = CakeFactory("chocolate", "medium")
        cake.addTopping("cherries")
        ingredients = cake.checkIngredients()

        self.assertIn("cherries", ingredients)
        self.assertIn("cocoa", ingredients)
        self.assertNotIn("vanilla extract", ingredients)

    def testCheckPrice(self):
        cake = CakeFactory("vanilla", "large")
        cake.addTopping("sprinkles")
        cake.addTopping("cherries")
        price = cake.checkPrice()

        self.assertEqual(price, 13)


if __name__ == "__main__":
    # unittest.main()
    unittest.TextTestRunner().run(unittest.TestLoader().loadTestsFromTestCase(TestCakeFactory))
