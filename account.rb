require_relative './helpers/messages'
require_relative './helpers/validations'
require 'yaml'
require 'pry'

class Account
  include Messages
  include Validations

  CARD_TYPES = { 
                  'usual' => { balance: 50.00, put: 0.02, withdraw: 0.05, send: 20 }, 
                  'capitalist' => { balance: 100.00, put: 10, withdraw: 0.04, send: 0.1 }, 
                  'virtual' => { balance: 150.00, put: 1, withdraw: 0.88, send: 1 } 
                }.freeze

  attr_accessor :name, :age, :login, :password, :card, :file_path

  def initialize
    @card = []
    @file_path = 'accounts.yml'
  end

  def console
    console_message

    case gets.chomp
    when 'create' then create
    when 'load' then load
    else exit
    end
  end

  def create
    until name && age && login && password
      name_input
      age_input
      login_input
      password_input
    end

    new_accounts = accounts << self
    @current_account = self
    File.open(@file_path, 'w') { |file| file.write new_accounts.to_yaml } # Storing
    main_menu
  end

  def load
    loop do
      if !accounts.any?
        return create_the_first_account
      end

      puts 'Enter your login'
      login = gets.chomp
      puts 'Enter your password'
      password = gets.chomp

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        a = accounts.select { |a| login == a.login }.first
        @current_account = a
        break
      else
        puts 'There is no account with given credentials'
        next
      end
    end
    main_menu
  end

  def create_the_first_account
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    case gets.chomp
    when 'y' then create
    else console
    end
  end

  def main_menu
    loop do
      main_menu_message(@current_account.name)
      case gets.chomp
      when 'SC' then show_cards
      when 'CC' then create_card
      when 'DC' then destroy_card
      when 'PM' then put_money
      when 'WM' then withdraw_money
      when 'SM' then send_money
      when 'DA'
        destroy_account
        exit
      when 'exit'
        exit
        break
      else puts 'Wrong command. Try again!'
      end
    end
  end

  def show_cards
    if @current_account.card.any?
      @current_account.card.each do |c|
        puts "- #{c[:number]}, #{c[:type]}"
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def create_card
    loop do
      create_card_message
      type = gets.chomp
      if CARD_TYPES.keys.include?(type)
        @current_account.card = @current_account.card << generate_card(type, CARD_TYPES[type][:balance])
        save_accounts
        break
      else wrong_card_type_message
      end
    end
  end

  def generate_card(type, balance)
    { type: type, number: generate_card_number, balance: balance }
  end

  def generate_card_number
    16.times.map { rand(10) }.join
  end

  def destroy_card
    destroy_card_message
    select_card do |card_index|
      destroy_card_confirm_message(@current_account.card[card_index][:number])
      return unless gets.chomp == 'y'

      @current_account.card.delete_at(card_index)
      save_accounts
      break
    end
  end

  def put_money
    puts 'Choose the card for putting:'
    select_card do |card_index|
      current_card = @current_account.card[card_index]
      puts 'Input the amount of money you want to put on your card'
      get_input_amount do |a2|
        if tax_amount(:put, current_card, a2.to_i) >= a2.to_i
          puts 'Your tax is higher than input amount'
          return
        else
          current_card[:balance] += (a2.to_i - tax_amount(:put, current_card, a2.to_i))
          save_accounts
          puts "Money #{a2.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{tax_amount(:put, current_card, a2.to_i)}"
          return
        end
      end
    end
  end

  def withdraw_money
    puts 'Choose the card for withdrawing:'
    select_card do |card_index|
      current_card = @current_account.card[card_index]
      puts 'Input the amount of money you want to withdraw'
      get_input_amount do |a2|
        money_left = current_card[:balance] - a2.to_i - tax_amount(:withdraw, current_card, a2.to_i)
        if money_left.positive?
          current_card[:balance] = money_left
          save_accounts
          puts "Money #{a2.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{tax_amount(:withdraw, current_card, a2.to_i)}$"
          return
        else
          puts "You don't have enough money on card for such operation"
          return
        end
      end
    end
  end

  def send_money
    puts 'Choose the card for sending:'
    select_card do |card_index|
      sender_card = @current_account.card[card_index]
      recipient_card = get_recipient_card
        puts 'Input the amount of money you want to withdraw'
        get_input_amount do |a3|
          return if not_enough_balance(sender_card[:balance], recipient_card, a3)
          sender_card[:balance] -= (a3.to_i + tax_amount(:send, sender_card, a3.to_i))
          recipient_card[:balance] += (a3.to_i - tax_amount(:put, recipient_card, a3.to_i))
          new_accounts = accounts.map do |account|
            case account.login
            when @current_account.login then @current_account
            when recipient_account.login then recipient_account
            else account
            end
          end
          File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml } #Storing
          puts "Money #{a3.to_i}$ was put on #{recipient_card[:number]}. Balance: #{recipient_card[:balance]}. Tax: #{tax_amount(:put, recipient_card, a3.to_i)}$\n"
          puts "Money #{a3.to_i}$ was put on #{sender_card[:number]}. Balance: #{sender_card[:balance]}. Tax: #{tax_amount(:send, sender_card, a3.to_i)}$\n"
        end
    end
  end

  def get_recipient_card
    puts 'Enter the recipient card:'
    answer = gets.chomp
    if answer.length == 16
      all_cards = accounts.map(&:card).flatten
      if all_cards.map(&:number).flatten.include?(answer)
        recipient_card = all_cards.select { |card| card if card[:number] == answer }.first
      else
        puts "There is no card with number #{answer}\n"
        return
      end
    else
      puts 'Please, input correct number of card'
      return
    end
    recipient_card
  end

  def get_recipient_account(card)
    accounts.select { |account| account if account.card.include?(card) }.first
  end

  def not_enough_balance(sender_balance, recipient_card, amount)
    if sender_balance < 0
      puts "You don't have enough money on card for such operation"
      return true
    elsif tax_amount(:put, recipient_card, amount.to_i) >= amount.to_i
      puts 'There is no enough money on sender card'
      return true
    end
    false
  end

  def select_card(&block)
    if @current_account.card.any?
      @current_account.card.each_with_index do |card, index|
        puts "- #{card[:number]}, #{card[:type]}, press #{index + 1}"
      end
      puts "press `exit` to exit\n"
      loop do
        answer = gets.chomp
        if answer.to_i.between?(1, @current_account.card.length)
          yield(answer.to_i - 1)
        elsif answer == 'exit'
          break
        else
          wrong_number_message
          break
        end
      end
    else
      no_active_cards_message
      return
    end
  end

  def get_input_amount(&block)
    amount = gets.chomp
    if amount.to_i.positive?
      yield(amount)
    else
      puts 'You must input correct amount of money'
    end
  end

  def check_tax(tax_type, card, amount)
    if tax_amount(tax_type, card, amount) >= amount
      puts 'Your tax is higher than input amount'
      return
    else
    end
  end

  def tax_amount(tax_type, card, amount)
    tax = CARD_TYPES[card[:type]][tax_type]
    if tax >= 1
      tax
    else
      amount * tax
    end
  end

  def destroy_account
    puts 'Are you sure you want to destroy account?[y/n]'
    if gets.chomp == 'y'
      new_accounts = accounts.reject { |account| account.login == @current_account.login }
      File.open(@file_path, 'w') { |file| file.write new_accounts.to_yaml } # Storing
    end
  end

  private

  def name_input
    puts 'Enter your name'
    input = gets.chomp
    @name = input if valid_name?(input)
  end

  def age_input
    puts 'Enter your age'
    input = gets.chomp.to_i
    @age = input if valid_age?(input)
  end

  def login_input
    puts 'Enter your login'
    input = gets.chomp
    @login = input if valid_login?(input, accounts.map(&:login))
  end

  def password_input
    puts 'Enter your password'
    input = gets.chomp
    @password = input if valid_password?(input)
  end

  def accounts
    if File.exists?('accounts.yml')
      YAML.load_file('accounts.yml')
    else
      []
    end
  end

  def save_accounts
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(account)
      end
    end
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
  end
end
