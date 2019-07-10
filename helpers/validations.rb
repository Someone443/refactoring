module Validations
  
  def valid_name?(input)
    unless !(input.empty?) && input.start_with?(/[A-Z]/)
      puts 'Your name must not be empty and starts with first upcase letter'
      return false
    end
    true
  end

  def valid_age?(input)
    unless input.is_a?(Integer) && input.between?(23, 90)
      puts 'Your Age must be greeter then 23 and lower then 90'
      return false
    end
    true
  end

  def valid_login?(input, collection)
    not_empty_login?(input) && valid_login_length?(input) && login_not_exist?(input, collection)
  end

  def not_empty_login?(input)
    if input.empty?
      puts 'Login must present'
      return false
    end
    true
  end

  def valid_login_length?(input)
    if input.length < 4
      puts 'Login must be longer then 4 symbols'
      return false
    elsif input.length > 20
      puts 'Login must be shorter then 20 symbols'
      return false
    end
    true
  end

  def login_not_exist?(input, collection)
    if collection.include?(input)
      puts 'Such account is already exists'
      return false
    end
    true
  end  

  def valid_password?(input)
    password_present?(input) && valid_password_length?(input)
  end

  def password_present?(input)
    if input.empty?
      puts 'Password must present'
      return false
    end
    true
  end

  def valid_password_length?(input)
    if input.length < 6
      puts 'Password must be longer then 6 symbols'
      return false
    elsif input.length > 30
      puts 'Password must be shorter then 30 symbols'
      return false
    end
    true
  end
end
