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
      url = URI("http://api.fixer.io/latest")
      body = Net::HTTP.get(url)
      self.rates=JSON.parse(body)["rates"]
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
