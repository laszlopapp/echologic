require 'singleton'
class Breadcrumb
  include Singleton
  
  def decode_terms(terms)
    terms.gsub(/\\;/, ',').gsub(/\\:;/, '|')
  end
  
  def encode_terms(terms)
    terms.gsub(/,/,'\\;').gsub(/\|/, '\\:;')
  end
end