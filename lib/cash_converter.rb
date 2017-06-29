require "cash_converter/version"
require 'date'
require 'net/http'
require 'json'
require 'bigdecimal'

module CashConverter

 class Money

   include Comparable

   attr_reader :amount, :currency

   def <=>(anOther)

     left_amount=self.amount
     right_amount=anOther.amount

     #if comparing different currencies, converting them to base currency
     left_amount= self.convert_to( CashConverter.config.base).amount  if self.currency !=  CashConverter.config.base
     right_amount=anOther.convert_to( CashConverter.config.base).amount  if self.currency !=  CashConverter.config.base

     left_amount <=> right_amount
   end

   def +(anOther)
     Money.new(self.amount + return_instance(anOther).amount, self.currency )
   end

   def -(anOther)
     Money.new(self.amount - return_instance(anOther).amount, self.currency )
   end

   def *(anOther)
     Money.new(self.amount * return_instance(anOther).amount, self.currency )
   end

   def /(anOther)
     Money.new(self.amount / return_instance(anOther).amount, self.currency )
   end
     

   def initialize(amount, currency)
     @amount=BigDecimal(amount.to_s).truncate(2)
     #can work only with currencies set in cofigs currency hash
     if CashConverter.config.rates.has_key? currency
       @currency=currency
       else raise NoSuchCurrency
     end

   end

   def inspect
     amount_string = @amount.to_s("F")
     #this is to show 00 after the decimal point, if there is only 1 symbol after it adds 0
     amount_string += "0" if amount_string.split('.')[1].length == 1
     "#{amount_string} #{@currency}"
   end

  def convert_to(target)
    #as we can work only with currencies defined in config raises error
    raise NoSuchCurrency unless CashConverter.config.rates.has_key? target

    if @currency !=  CashConverter.config.base
      amount =(@amount/CashConverter.config.rates[@currency]) * CashConverter.config.rates[target]
    else
      amount =   @amount * CashConverter.config.rates[target]
    end

    Money.new(amount,target)
  end


   private
   #this method is for arifmetics, when he catches somthing beside Money class object, he converts it to left side currency
   def return_instance(object)
     if object.instance_of? Money
       other = object.convert_to(self.currency)
     else
       other = Money.new(object,self.currency)
     end
    other
   end

 end

 class NoSuchCurrency < StandardError
   def initialize(msg="You should provide this currency in config file via rates param")
     super
   end
 end

 #this is for using default data in config
  DefaultConfig = Struct.new(:base, :date, :rates) do
    def initialize
      self.base = "EUR"
      self.date =  Date.today.to_s
      self.rates = Hash.new
      begin
        #getting base rates for EUR for today
        url = URI("http://api.fixer.io/latest")
        body = Net::HTTP.get(url)
        self.rates = JSON.parse(body)["rates"]
        #adding base value for cross conversions
        self.rates[self.base]=1
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        puts "Please set up rates via config"
      end
    end
  end

 #getting data from config

  def self.configure
    @config = DefaultConfig.new
    yield(@config) if block_given?
    @config
  end

  def self.config
    @config || configure
  end

end
