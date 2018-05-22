class Deck
  SUITS = %w[♦️ ♣️ ♠️ ♥️].freeze
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

  attr_reader :cards

  def initialize
    @cards = build_deck
  end

  def deal(num = 1)
    num == 1 ? cards.pop : cards.pop(num)
  end

  private

  def build_deck
    SUITS.each_with_object([]) do |suit, a|
      RANKS.each do |rank|
        a << Card.new(rank, suit)
      end
    end.shuffle!
  end
end
