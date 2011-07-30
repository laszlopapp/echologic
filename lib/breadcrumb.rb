require 'singleton'
class Breadcrumb
  include Singleton
  
  def decode_terms(terms)
    terms ? terms.gsub(/\\;/, ',').gsub(/\\:;/, '|') : nil
  end
  
  def encode_terms(terms)
    terms ? terms.gsub(/,/,'\\;').gsub(/\|/, '\\:;') : nil
  end

  def origin_keys
    ["sr","ds","mi","fq","jp"]
  end
  
  def generate_key(name)
    case name
      when "proposal" then 'pr'
      when "improvement" then 'im'
      when "pro_argument","contra_argument" then 'ar'
      when "background_info" then 'bi'
      when "follow_up_question" then 'fq'
    end
  end
end