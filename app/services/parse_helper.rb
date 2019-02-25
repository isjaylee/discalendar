module ParseHelper
  extend self

  def strings_in_quotes(string)
    string.scan(/"([^"]*)"/).flatten
  end
end