class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!
  use_session!

  def start
    respond_with :message, text: t('start_menu.welcome', bank: Game::INITIAL_BANK, bet: Game::BET), reply_markup:
      {
        keyboard: start_menu,
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      }
  end

  def message(message)
    case message['text']
    when t('start_menu.action.new_game')
      create_and_save_game

      respond_with :message, text: telegram_output(@game), parse_mode: :html, reply_markup:
        { inline_keyboard: telegram_keyboard(@game.actions) }
    else
      respond_with :message, text: t('start_menu.action.missing_message')
    end
  end

  def callback_query(data)
    load_game_from_session

    if data.to_sym == :game_over || !@game
      @game = session[:game] = nil

      respond_with :message, text: t('start_menu.goodbye'), parse_mode: :html, reply_markup:
        {
          keyboard: start_menu,
          resize_keyboard: true,
          one_time_keyboard: true,
          selective: true
        }
    else
      actions = @game.next_step(data.to_sym)
      respond_with :message, text: telegram_output(@game), parse_mode: :html, reply_markup:
        { inline_keyboard: telegram_keyboard(actions) }
    end
  end

  private

  def create_and_save_game
    @game = session[:game] = Game.new
  end

  def load_game_from_session
    @game = session[:game]
  end

  def start_menu
    [[{ text: t('start_menu.action.new_game') }]]
  end

  def telegram_output(game)
    out = ''
    out << t('game.message.dealer_cards', cards: game.dealer_cards)
    out << t('game.message.dealer_score', score: game.dealer_score)
    out << t('game.message.separator')
    out << t('game.message.player_cards', cards: game.player_cards)
    out << t('game.message.player_score', score: game.player_score)
    if game.result
      out << t('game.message.separator')
      out << t('game.message.result', result: t("game.result.#{game.result}"))
      out << t('game.message.separator')
      out << t('game.message.dealer_bank', bank: game.dealer_bank)
      out << t('game.message.player_bank', bank: game.player_bank)
      out << t('game.message.separator')
    end
    out
  end

  def telegram_keyboard(actions)
    actions.reduce([]) { |arr, action| arr << [text: t("game.action.#{action}"), callback_data: action] }
  end
end
