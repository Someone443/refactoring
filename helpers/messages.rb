module Messages
  def console_message
    puts 'Hello, we are RubyG bank!'
    puts '- If you want to create account - press `create`'
    puts '- If you want to load account - press `load`'
    puts '- If you want to exit - press `exit`'
  end

  def main_menu_message(account_name)
    puts "\nWelcome, #{account_name}"
    puts 'If you want to:'
    puts '- show all cards - press SC'
    puts '- create card - press CC'
    puts '- destroy card - press DC'
    puts '- put money on card - press PM'
    puts '- withdraw money on card - press WM'
    puts '- send money to another card  - press SM'
    puts '- destroy account - press `DA`'
    puts '- exit from account - press `exit`'
  end

  def create_card_message
    puts 'You could create one of 3 card types'
    puts '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`'
    puts '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`'
    puts '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`'
    puts '- For exit - press `exit`'
  end

  def wrong_card_type_message
    puts 'Wrong card type. Try again!'
  end

  def destroy_card_message
    puts 'If you want to delete:'
  end

  def destroy_card_confirm_message(card_number)
    puts "Are you sure you want to delete #{card_number}?[y/n]"
  end

  def wrong_number_message
    puts 'You entered wrong number!'
  end

  def no_active_cards_message
    puts 'There is no active cards!'
  end
end
