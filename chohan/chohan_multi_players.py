import random, sys, os
from player_dice import PlayerChoHan, ChoHan

# TODO:
# .add code if Snake Eyes
# .add bonus if bet at certain amount

prompt = """
In this traditional Japanese dice game, two dice are rolled in a bamboo cup by
the dealer sitting on the floor. The player must guess if the dice total to an
even (cho) or odd (han) number.
"""


def main():

    print('Cho Han game!')
    print(prompt)
    print("\n" + '-' * 35)

    # get players
    players = getPlayers()
    printPlayers(players)

    while True:

        # players place bet
        getBet(players)

        # throwing dice
        print("\n" + '-' * 35)
        chohan = ChoHan()
        chohan.rolling()
        chohan.updateChoHan()

        # players guess
        betting(players)

        # displaying result
        print("\n" + '-' * 35)
        chohan.showingResult()

        # check result for each player
        print("\n" + '-' * 35)
        checkGuessAndUpdateBet(players, chohan.result)
        printPlayers(players)

        print("\n" + '=' * 35)
        keepPlaying = input('Continue to play? (y/n) > ').lower()
        while True:
            if keepPlaying == 'n':
                print('\nBelow is the final balance for all players:')
                printPlayers(players)
                return
            if keepPlaying == 'y':
                break


def checkGuessAndUpdateBet(players, result):
    for p in players:
        if p.guess != "":
            if p.guess == result:
                print(f"{p.name} won! You take {p.bet} yen.")
                houseFee = p.bet // 10
                print(f"The house collects a {houseFee} yen fee.")
                p.balance += p.bet - houseFee

            else:
                print(f"{p.name} lost {p.bet} yen!")
                p.balance -= p.bet

        # reset 'bet' & 'guess'
        p.bet = 0
        p.guess = ""
        print()


def betting(players):
    for p in players:
        if p.bet != 0:
            print(f"{p.name}, please enter your guess ", end="")
            while p.guess not in ['CHO', 'HAN']:
                p.guess = input('> ').upper()


def getBet(players):
    for p in players:
        print(f"\n{p.name}, you have {p.balance:,} yen. How much do you bet? (or 'Enter' to skip this round)")

        while True:
            bet = input('> ')
            if bet == '':
                print(f"{p.name} skips this round.")
                break

            elif bet.isdecimal():
                if int(bet) <= 0:
                    print('Please enter a valid bet.')
                elif int(bet) > p.balance:
                    print(f'You have insufficient money to bet {bet}.\nPlease try another amount ', end='')
                else:
                    print(f"{p.name} bets {int(bet):,}")
                    p.bet = int(bet)
                    break


def currentBal(bal):
    print(f"\nBalance: {bal:,}")


def getPlayers():
    prompt = """
How many players will be playing?
Please enter a numbers of players follow by their names with 'space'.
- E.g. 3 Tina Kamy Ngoc
- Else, please press enter to continue if only 1 player is playing
"""
    print(prompt)

    while True:
        numberOfPlayers = input('> ')

        if numberOfPlayers == '':
            return [PlayerChoHan()]
        else:
            # simplify by only accept the correct input
            # without much 'print' explanation
            # let the player inputs in valid form as per instruction
            playersData = numberOfPlayers.split(' ')
            num = playersData[0]
            if num.isdecimal() and int(num) == len(playersData[1:]):
                return [PlayerChoHan(player.upper()) for player in playersData[1:]]


def printPlayers(players):
    if len(players) == 1:
        for p in players:
            currentBal(p.balance)
    else:
        """sample:
        Player  | Balance
        --------|-----------
        Player1 | 1,000
        Player2 | 1,000
        Player3 | 1,000
        """
        records = f"\n{'Player':<10}| {'Balance':<12}\n"
        records += "-" * 10 + "|" + "-" * 12 + "\n"

        for p in players:
            records += f"{p.name:<10}| {p.balance:<12,}\n"

        print(records)


if __name__ == '__main__':
    os.system('clear')
    main()
