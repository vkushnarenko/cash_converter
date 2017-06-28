require "spec_helper"

RSpec.describe CashConverter do
  it "has a version number" do
    expect(CashConverter::VERSION).not_to be nil
  end

  it "has default config data" do
    expect(CashConverter.config.base).to eq("EUR")
    expect(CashConverter.config.date).to eq(Date.today.to_s)
    expect(CashConverter.config.rates).to include("USD","JPY")
  end


  it "can be configured" do
    CashConverter.configure do |config|
      config.base = "EUR"
      config.date = "2017-06-28"
      config.rates =  {
          "AUD" => 1.4986,
          "BGN" => 1.9558,
          "BRL" => 3.7632,
          "CAD" => 1.4888,
          "CHF" => 1.0913,
          "CNY" => 7.7348,
          "CZK" => 26.326,
          "DKK" => 7.4366,
          "GBP" => 0.88525,
          "HKD" => 8.8759,
          "HRK" => 7.4128,
          "HUF" => 309.54,
          "IDR" => 15160,
          "ILS" => 4.004,
          "INR" => 73.434,
          "JPY" => 127.53,
          "KRW" => 1300.6,
          "MXN" => 20.434,
          "MYR" => 4.8922,
          "NOK" => 9.602,
          "NZD" => 1.5648,
          "PHP" => 57.518,
          "PLN" => 4.2375,
          "RON" => 4.551,
          "RUB" => 67.901,
          "SEK" => 9.778,
          "SGD" => 1.5752,
          "THB" => 38.675,
          "TRY"=> 4.0079,
          "USD" => 1.1375,
          "ZAR" => 14.808
      }
    end

    expect(CashConverter.config.base).to eq("EUR")
    expect(CashConverter.config.date).to eq("2017-06-28")
    expect(CashConverter.config.rates).to include("USD" => 1.1375)
  end

  it "raises error when setting unexistant method to config" do
    CashConverter.configure do |config|
      expect {config.unknown_attribute = "TestName"}.to raise_error(NoMethodError)
    end
  end

  it "raises error when getting unexistant method to config" do
    expect {CashConverter.config.unknown_attribute}.to raise_error(NoMethodError)
  end

end
