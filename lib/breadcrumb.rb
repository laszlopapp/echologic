require 'singleton'
class Breadcrumb
  include Singleton
  
  def decode_terms(terms)
    terms.gsub(/\\;/, ',').gsub(/\\:;/, '|')
  end
  
  def encode_terms(terms)
    terms.gsub(/,/,'\\;').gsub(/\|/, '\\:;')
  end
  
  def generate_key(name)
    case name
      when "proposal" then 'pr'
      when "improvement" then 'im'
      when "pro_argument","contra_argument" then 'ar'
      when "follow_up_question" then 'fq'
    end
  end
end