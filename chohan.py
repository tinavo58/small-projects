import random, sys, os

JAPANESE_NUMBERS = {
    1: ('ichi', '⚀'),
    2: ('ni', '⚁'),
    3: ('san', '⚂'),
    4: ('shi', '⚃'),
    5: ('go', '⚄'),
    6: ('roku', '⚅')
}

BALANCE = 5_000

prompt = """
In this traditional Japanese dice game, two dice are rolled in a bamboo cup by
the dealer sitting on the floor. The player must guess if the dice total to an
even (cho) or odd (han) number.
"""

diceRolling = """

The dealer swirls the cup and you hear the rattle of dice.
The dealer slams the cup on the floor, still covering the
dice and asks for your bet.

    CHO (even) or HAN (odd)?
"""

def main():
    global BALANCE
    print('Cho Han game!')
    print(prompt)
    while True:
        print("\n" + '-' * 35)
        currentBal()
        print(f"\nYou have {BALANCE:,} yen. How much do you bet? (or 'q' to QUIT)")
        bet = input('> ')

        while True:
            if bet == 'q':
                sys.exit()

            if bet.isdecimal():
                if int(bet) <= 0:
                    print('Please enter a valid bet.')
                elif int(bet) > BALANCE:
                    print(f'You have insufficient money to bet {bet}.\nPlease try another amount.')
                else:
                    bet = int(bet)
                    break

        print(diceRolling)

        # rolling dice
        dice1 = random.randint(1, 6)
        dice2 = random.randint(1, 6)

        if (dice1 + dice2) % 2 == 0:
            result = 'CHO'
        else:
            result = 'HAN'

        guess = input('> ').upper()

        while guess not in ['CHO', 'HAN']:
            guess = input('> ').upper()

        # showing the dice
        print('\nThe dealer lifts the cup to reveal:')
        print(f"{JAPANESE_NUMBERS[dice1][0].upper():^10} - {JAPANESE_NUMBERS[dice2][0].upper():^10}")
        print(f"{JAPANESE_NUMBERS[dice1][1]:^10} - {JAPANESE_NUMBERS[dice2][1]:^10}")
        print(f"{dice1:^10} - {dice2:^10}")
        print()

        if guess == result:
            print(f"You won! You take {bet} yen.")
            houseFee = bet // 10
            print(f"The house collects a {houseFee} yen fee.")
            BALANCE += bet - houseFee
        else:
            print(f"You lost {bet} yen!")
            BALANCE -= bet

        currentBal()


def currentBal():
    print(f"Current balance: {BALANCE:,}")


if __name__ == '__main__':
    os.system('clear')
    main()
