
## ROLES
{ :admin => %w(),
  :editor => %w()
}.each_pair { |role, users| users.each { |user| user.has_role!(role) } }

## CATEGORIES
%w(echonomyjam echocracy echo echosocial).each { |name| Tag.create(:value => name) }

### ENUM KEYS
##LANGUAGES
#%w(en de fr pt).each_with_index do |code, index| 
#  EnumKey.create!(:code => code, :name => "languages", :key => index+1, :description => "languages")
#end
##LANGUAGE LEVELS
#%w(mother_tongue advanced intermediate basic).each_with_index do |code, index| 
#  EnumKey.create!(:code => code, :name => "language_levels", :key => index+1, :description => "language_levels")
#end
##WEB ADDRESSES  
#%w(email homepage blog xing linked_in facebook twitter).each_with_index do |code, index| 
#  EnumKey.create!(:code => code, :name => "web_addresses", :key => index, :description => "web_addresses")
#end
#EnumKey.create!(:code => 'other', :name => "web_addresses", :key => 99, :description => "web_addresses")
##ORGANISATIONAL TYPES
#%w(ngo political scientific trade_union social_business profit_driven_business).each_with_index do |code, index| 
#  EnumKey.create!(:code => code, :name => "organisation_types", :key => index+1, :description => "organisation_types")
#end
#  
##TAG CONTEXTS
#%w(affection engagement expertise decision_making field_work field_activity).each_with_index do |code, index| 
#  EnumKey.create!(:code => code, :name => "tag_contexts", :key => index+1, :description => "tag_contexts")
#end
#
###ENUM VALUES
#
##Languages
#["English","Englisch","Ingles","Inglês"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('en'), :language_id => index+1, :value => value, :context => "")
#end
#["German","Deutsch","Aleman","Alemão"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('de'), :language_id => index+1, :value => value, :context => "")
#end
#["French","Französisch","Français","Francês"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('fr'), :language_id => index+1, :value => value, :context => "")
#end
#["Portuguese","Portugiesisch","Portugais","Português"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('pt'), :language_id => index+1, :value => value, :context => "")
#end
#
##Language Level
#["Mother Tongue","Muttersprache","Langue Maternelle","Língua Materna"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('mother_tongue'), :language_id => index+1, :value => value, :context=> "")
#end
#["Advanced","Fortgeschritten","Avancé","Avançado"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('advanced'), :language_id => index+1, :value => value, :context=> "")
#end
#["Intermediate","Mittelstufe","Intermédiaire","Intermédio"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('intermediate'), :language_id => index+1, :value => value, :context=> "")
#end
#["Basic","Grundkenntnisse","Basique","Básico"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('basic'), :language_id => index+1, :value => value, :context=> "")
#end
##Web Addresses
#EnumKey.languages.length.times do |index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('email'), :language_id => index+1, :value => "E-mail", :context=> "")
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('homepage'), :language_id => index+1, :value => "Homepage", :context=> "")
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('blog'), :language_id => index+1, :value => "Blog", :context=> "")
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('xing'), :language_id => index+1, :value => "Xing", :context=> "")
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('linked_in'), :language_id => index+1, :value => "LinkedIn", :context=> "")
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('facebook'), :language_id => index+1, :value => "Facebook", :context=> "")
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('twitter'), :language_id => index+1, :value => "Twitter", :context=> "")
#end 
#["Other","Andere","Autre","Outro"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('other'), :language_id => index+1, :value => value, :context=> "")
#end
##Organization Types  
#["NGO","NRO","ONG","ONG"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('ngo'), :language_id => index+1, :value => value, :context=> "")
#end  
#["Political","Politisch","Politique","Política"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('political'), :language_id => index+1, :value => value, :context=> "")
#end 
#["Scientific","Wissenschaftlich","Scientifique","Científica"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('scientific'), :language_id => index+1, :value => value, :context=> "")
#end  
#["Trade Union","Gewerkschaft","Syndicat","Sindicato"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('trade_union'), :language_id => index+1, :value => value, :context=> "")
#end  
#["Social Business","Sozialbetrieb","Activité Sociale","Actividade Social"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('social_business'), :language_id => index+1, :value => value, :context=> "")
#end   
#["Profit-Driven Business","Gewinnorientierte Firma","Firma à but lucratif","Firma com fins lucrativos"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('profit_driven_business'), :language_id => index+1, :value => value, :context=> "")
#end 
##Tag Contexts
#["Affection","Betroffenheit","Affection","Afeição"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('affection'), :language_id => index+1, :value => value, :context=> "")
#end   
#["Engagement","Engagement","Engagement","Compromisso"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('engagement'), :language_id => index+1, :value => value, :context=> "")
#end  
#["Expertise","Expertise","Expertise","Especialidade"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('expertise'), :language_id => index+1, :value => value, :context=> "")
#end  
#["Decision Making","Entscheidung","Décision","Decisão"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('decision_making'), :language_id => index+1, :value => value, :context=> "")
#end 
#["Field of Work","Arbeitsfeld","Domaine de travail","Domínio de Trabalho"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('field_work'), :language_id => index+1, :value => value, :context=> "")
#end
#["Field of Activity","Aktivitätsfeld","Domaine d'activité","Domínio de Actividade"].each_with_index do |value,index|
#  EnumValue.create!(:enum_key => EnumKey.find_by_code('field_work'), :language_id => index+1, :value => value, :context=> "")
#end
#  
