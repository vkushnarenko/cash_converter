require "cash_converter/version"
require 'date'
require 'net/http'
require 'json'
require 'bigdecimal'

module CashConverter

 class Money

   attr_reader :amount, :currency

   def initialize(amount, currency)
     @amount=BigDecimal(amount.to_s).truncate(2)

     if CashConverter.config.rates.has_key? currency
       @currency=currency
       else raise NoSuchCurrency
     end

   end

   def inspect
     amount_string = @amount.to_s("F")
     amount_string += "0" if amount_string.split('.')[1].length == 1
     "#{amount_string} #{@currency}"
   end

  def convert_to(target)
    raise NoSuchCurrency unless CashConverter.config.rates.has_key? target
    amount = @amount * CashConverter.config.rates[target]
    Money.new(amount,target)
  end

 end

 class NoSuchCurrency < StandardError
   def initialize(msg="You should provide this currency in config file via rates param")
     super
   end
 end

  DefaultConfig = Struct.new(:base, :date, :rates) do
    def initialize
      self.base = "EUR"
      self.date =  Date.today.to_s
      self.rates = Hash.new
      begin
        url = URI("http://api.fixer.io/latest")
        body = Net::HTTP.get(url)
        self.rates = JSON.parse(body)["rates"]
        self.rates[self.base]=1
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        puts "Please set up rates via config"
      end
    end
  end

  def self.configure
    @config = DefaultConfig.new
    yield(@config) if block_given?
    @config
  end

  def self.config
    @config || configure
  end

end
