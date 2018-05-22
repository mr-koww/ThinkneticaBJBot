# Status: :round, :end_round, :game_over
# Result: :player_round, :dealer_round, :draw_round, :player_won, :dealer_won

class Game
  INITIAL_BANK = 100
  BET = 10
  STOP_DEALER_SCORE = 17
  ROUND_ACTIONS = %i[get_card skip_move]
  END_ROUND_ACTIONS = %i[new_round game_over]
  DEALER_COVERED_MASK = '* * * * *'

  attr_reader :status, :result

  def initialize
    start_round(INITIAL_BANK, INITIAL_BANK)
  end

  def next_step(action)
    do_action(action)
    available_actions
  end

  def actions
    available_actions
  end

  def player_cards
    @player_hand.to_s
  end

  def dealer_cards
    status == :round ? DEALER_COVERED_MASK : @dealer_hand.to_s
  end

  def player_score
    @player_hand.score
  end

  def dealer_score
    status == :round ? DEALER_COVERED_MASK : @dealer_hand.score
  end

  def player_bank
    @player_hand.bank
  end

  def dealer_bank
    @dealer_hand.bank
  end

  private

  def start_round(player_bank, dealer_bank)
    @deck = Deck.new
    @player_hand = Hand.new(@deck.deal(2), player_bank)
    @dealer_hand = Hand.new(@deck.deal(2), dealer_bank)
    @status = :round
    @result = nil
  end

  def do_action(action)
    return unless can_action?(action)

    case action
      when :new_round
        start_round(@player_hand.bank, @dealer_hand.bank)
      when :get_card
        @player_hand.add_card(@deck.deal)
        round if @player_hand.score >= 21
      when :skip_move
        @dealer_hand.add_card(@deck.deal) while @dealer_hand.score < STOP_DEALER_SCORE
        round
    end
  end

  def round
    if @player_hand.score < 21
      return player_round if @dealer_hand.score > 21
      return draw_round if @player_hand.score == @dealer_hand.score
      @player_hand.score > @dealer_hand.score ? player_round : dealer_round
    elsif @player_hand.score == 21
      @dealer_hand.score == @player_hand.score ? draw_round : player_round
    else
      @dealer_hand.score <= 21 ? dealer_round : draw_round
    end
  end

  def available_actions
    case status
      when :round
        ROUND_ACTIONS
      when :end_round
        END_ROUND_ACTIONS
      when :game_over
        []
    end
  end

  def can_action?(action)
    if status == :end_round
      END_ROUND_ACTIONS.include?(action)
    elsif status == :round
      ROUND_ACTIONS.include?(action)
    else
      false
    end
  end

  def player_round
    @player_hand.increase_bank(BET)
    @dealer_hand.decrease_bank(BET)
    @result = :player_round
    @status = :end_round
    game_over?
  end

  def dealer_round
    @dealer_hand.increase_bank(BET)
    @player_hand.decrease_bank(BET)
    @result = :dealer_round
    @status = :end_round
    game_over?
  end

  def draw_round
    @result = :draw_round
    @status = :end_round
  end

  def game_over?
    if @player_hand.bank.zero?
      @status = :game_over
      @result = :dealer_won
    elsif @dealer_hand.bank.zero?
      @status = :game_over
      @result = :player_won
    end
  end
end
