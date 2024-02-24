from typing import List

class CakeFactory:
    def __init__(self, cakeType: str, size: str) -> None:
        self.cakeType = cakeType
        self.size = size
        self.toppings = []

        # price based on type & size
        self.price = 10 if self.cakeType == "chocolate" else 8
        self.price += 2 if self.size == "medium" else 4 if self.size == "large" else 0

    def addTopping(self, topping: str) -> None:
        self.toppings.append(topping)
        # add price
        self.price += 1

    def checkIngredients(self) -> List[str]:
        ingredients = ['flour', 'sugar', 'eggs']
        ingredients.append('cocoa') if self.cakeType == "chocolate" else ingredients.append('vanilla extract')
        ingredients += self.toppings
        return ingredients

    def checkPrice(self) -> float:
        return self.price


if __name__ == "__main__":
    cake = CakeFactory("small", "strawberry")
    print(cake.checkPrice())

    cake.addTopping("berry")
    cake.addTopping("peanut")
    cake.addTopping("coconut flake")
    print(cake.checkIngredients())
    print(cake.checkPrice())
