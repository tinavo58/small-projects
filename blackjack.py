import itertools, sys, random, os, time

"""this game is playes with just one deck
and no splitting is allowed"""

hidden_card_template = [
    " ___  ",
    "|## | ",
    "|###| ",
    "|_##| "
]

ace_11_court_cards = dict(A=11, J=10, Q=10, K=10)
ace_1_court_cards = dict(A=1, J=10, Q=10, K=10)

def getDeck():
    ranks = list(range(2, 11))   + ['A', 'J', 'Q', 'K']
    suits = ['❤︎', '♠︎', '♦︎', '♣︎']
    deck = list(itertools.product(ranks, suits))
    random.shuffle(deck)
    return deck

def drawCards(list_cards, template=[""]*4):
    cards = template.copy() # create a copy of the template
    for rank, suit in list_cards:
        cards[0] += " ___  "
        cards[1] += "|{} | ".format(str(rank).ljust(2)) # default ' ' as fillchar
        cards[2] += "| {} | ".format(suit)
        cards[3] += "|_{}| ".format(str(rank).rjust(2, '_'))

    for each in cards:
        print(each)

def total_rank(list_cards):
    total = 0
    ranks = [each[0] for each in list_cards]

    if len(ranks) == ranks.count('A') == 2:
        return 12

    def get_total(map_dict):
        return sum(map(lambda rank: map_dict.get(rank, rank), ranks))

    total = get_total(ace_11_court_cards)

    if len(ranks) > 2 and 'A' in ranks and total > 21:
        total = get_total(ace_1_court_cards)

    if ranks.count('A') >= 2 and total + 10 <= 21:
        return total + 10

    return total

def showCardsValue(who='dealer', value="???"):
    # show default value: DEALER: ???
    print(f"\n{who.upper()}: {value}")

def displayInfo(list_cards, who='dealer'):
    total = total_rank(list_cards)
    showCardsValue(who, value=total)
    drawCards(list_cards)

def hitCard(list_cards, who='player'):
    card = deck.pop()
    list_cards.append(card)
    rank, suit = card
    if who == 'player':
        print(f"\nYou drew a {rank} of {suit}")

def printBetAmount(amt):
    print(f"Bet: ${amt:,}")

def addToBal(amt):
    global BALANCE
    BALANCE += amt
    print(f"\nYou won ${amt:,}")

def deductFromBal(amt):
    global BALANCE
    BALANCE -= amt
    print(f'\nDealer won! You lost ${amt:,}')


#-------------------------------------------------------------------------
rules = """
Welcome to Blackjack!

Rules:
    .Try to get as close to 21 without going over.

    .Kings, Queens and Jacks are with 10 points.
    .Aces are worth 1 or 11 points.
    .Cards 2 through 10 are worth their face value.

    .(H)it to take another card.
    .(S)tand to stop taking cards.
    .On your first play, you can (D)ouble down to increase your bet
    but must hit exactly one more time before standing.

    .In case of a tie, the bet is returned to the player.
    .The dealer stops hitting at 17.

"""

deck = getDeck()
BALANCE = 5_000

print(rules)

while len(deck) > 9: # assume 5 each for player and dealer

    # check if BALANCE is > 0
    if BALANCE < 1:
        print(f"\nYour current balance: ${BALANCE:,}")
        print('You have insufficinet balance to continure playing.')
        time.sleep(3)
        sys.exit()

    print('\n'+ '=' * 35)
    print(f"\nYour current balance: ${BALANCE:,}")

    if BALANCE == 1:
        print(f"\nHow much do you want to bet? ($1 or 'q' to quit)")
    else:
        print(f"\nHow much do you want to bet? ($1 - ${BALANCE:,} or 'q' to quit)")

    while True:
        bet = input('> ')

        if bet.lower() == 'q':
            sys.exit()

        # check if bet is valid
        # 1st check if input could be converted into a number with no decimal
        # before checking the condition
        if bet.isdecimal():
            if int(bet) > BALANCE:
                print("Your balance is insufficient.\n")
            elif 0 < int(bet) <= BALANCE:
                bet = int(bet)
                printBetAmount(bet)
                break

    # dealer cards
    dealer_cards = [deck.pop(), deck.pop()]
    dealer_total = total_rank(dealer_cards)
    showCardsValue()
    drawCards(dealer_cards[1:], template=hidden_card_template)

    # player cards
    player_cards = [deck.pop(), deck.pop()]
    player_total = total_rank(player_cards)
    displayInfo(player_cards, 'player')

    player_choice = []

    while player_total < 21:
        print("\n(H)it, (S)tand, (D)ouble down")
        selection = ""
        while selection not in ['H', 'S', 'D']:
            selection = input('> ').upper()

        player_choice.append(selection)

        if selection == "H":
            hitCard(player_cards)
            player_total = total_rank(player_cards)
            displayInfo(player_cards, 'player')

        elif selection == 'D':
            if bet * 2 > BALANCE:
                print("You are unable to (D)ouble due to insufficient balance.")
                player_choice.pop()
            elif not len(player_choice) > 1:
                bet *= 2
                printBetAmount(bet)
            else:
                print("You can only (D)ouble once when the 1st two cards were drawn.")

        elif selection == 'S':
            if len(player_choice) > 1 and player_choice[0] == 'D' and not player_choice[1] == 'H':
                print("You need to (H)it after (D)ouble.")
            else:
                displayInfo(player_cards, 'player')
                break

        print()

    while dealer_total < 17: # regardless if player is busted
        hitCard(dealer_cards, who='dealer')
        dealer_total = total_rank(dealer_cards)

    print()
    print('-' * 35)

    displayInfo(dealer_cards)
    displayInfo(player_cards, 'player')

    if dealer_total == player_total or\
        (player_total > 21 and dealer_total > 21):
        print(f"\nNo one won!")
    elif (dealer_total > 21 or player_total > dealer_total)\
        and player_total <=21:
        addToBal(bet)
    else: # dealer <=21
        if player_total > 21 or player_total < dealer_total:
            deductFromBal(bet)

    time.sleep(5)
    os.system('clear')

print("Not enough cards in the deck!")
print(f"\nYour current balance: ${BALANCE:,}")