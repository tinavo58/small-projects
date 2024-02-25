import pytest
from typing import List

class Fruit:
    def __init__(self, name) -> None:
        self.name = name
        self.cubed = False

    def cube(self):
        self.cubed = True


class FruitSalad:
    def __init__(self, *fruit_bowl: List[Fruit]) -> None:
        self.fruit = fruit_bowl
        self._cube_fruit()


    def _cube_fruit(self):
        for fruit in self.fruit:
            fruit.cube()


# arrange
@pytest.fixture
def fruit_bowl():
    return [Fruit('apple'), Fruit('banana')]


def testFruitSalad(fruit_bowl):
    # act
    fruitSalad = FruitSalad(*fruit_bowl)

    # assert
    assert all(fruit.cubed for fruit in fruitSalad.fruit)
