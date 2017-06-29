require "cash_converter/version"
require 'date'
require 'net/http'
require 'json'

module CashConverter

  # Your code goes here...
  DefaultConfig = Struct.new(:base, :date, :rates) do
    def initialize
      self.base = "EUR"
      self.date =  Date.today.to_s
      begin
        url = URI("http://api.fixer.io/latest")
        body = Net::HTTP.get(url)
        self.rates=JSON.parse(body)["rates"]
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
