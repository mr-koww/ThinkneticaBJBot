 class Hand
  attr_reader :cards, :bank

  def initialize(cards, bank)
    @cards = cards
    @bank = bank
  end

  def add_card(card)
    cards << card
  end

  def increase_bank(bet)
    @bank += bet
  end

  def decrease_bank(bet)
    @bank -= bet
  end

  def score
    cards.reduce(0) do |amount, card|
      if card.face_card?
        amount + 10
      elsif card.ace_card?
        if amount <= 10
          amount + 10
        else
          amount + 1
        end
      else
        amount + card.rank.to_i
      end
    end
  end

  def to_s
    cards.reduce('') do |s, card|
      s << card.to_s << ' | '
    end
  end
end
