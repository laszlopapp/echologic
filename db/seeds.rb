# USER ROLES
{ :admin => %w(),
  :editor => %w(),
  :topic_editor => %w()
}.each_pair { |role, users| users.each { |user| user.has_role!(role) } }

# TOPIC CATEGORIES
#%w(#echonomyjam #echocracy #echo #echosocial #realprices #igf #klimaherbsttv).each { |name| Tag.create(:value => name) }


###############
#  ENUM KEYS  #
###############

# LANGUAGES
%w(en de fr pt es).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "Language", :key => index+1, :description => "language")
end

# LANGUAGE LEVELS
%w(mother_tongue advanced intermediate basic).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "LanguageLevel", :key => index+1, :description => "language_level")
end

# WEB ADDRESSES
%w(email homepage blog xing linkedin facebook twitter).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "WebAddressType", :key => index+1, :description => "web_address_type")
end
EnumKey.create(:code => 'other', :type => "WebAddressType", :key => 99, :description => "web_address_type")

# ORGANISATION TYPES
%w(ngo political scientific trade_union social_business profit_driven_business).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "OrganisationType", :key => index+1, :description => "organisation_type")
end

# TAG CONTEXTS
%w(affection engagement expertise decision_making field_work field_activity topic).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "TagContext", :key => index+1, :description => "tag_context")
end

# STATEMENT STATES
%w(new published).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "StatementState", :key => index+1, :description => "statement_state")
end

# STATEMENT DOCUMENT ACTIONS
%w(created updated translated incorporated).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "StatementAction", :key => index+1, :description => "statement_action")
end

# COLLABORATION TEAM
%w(core_team supporters alumni technology_partners financial_partners).each_with_index do |code, index|
  EnumKey.create(:code => code, :type => "CollaborationTeam", :key => index+1, :description => "collaboration_team")
end

#################
#  ENUM VALUES  #
#################

# Languages
["English","Englisch","Ingles","Inglês","Inglés"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('en'), :code => Language.find_by_key(index+1).code, :value => value, :context => "")
end
["German","Deutsch","Aleman","Alemão","Alemán"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('de'), :code => Language.find_by_key(index+1).code, :value => value, :context => "")
end
["French","Französisch","Français","Francês","Francés"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('fr'), :code => Language.find_by_key(index+1).code, :value => value, :context => "")
end
["Portuguese","Portugiesisch","Portugais","Português","Portugués"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('pt'), :code => Language.find_by_key(index+1).code, :value => value, :context => "")
end
["Spanish","Spanisch","Espagnol","Espanhol","Español"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('es'), :code => Language.find_by_key(index+1).code, :value => value, :context => "")
end

# Language Levels
["Mother Tongue","Muttersprache","Langue Maternelle","Língua Materna","Lengua Materna"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('mother_tongue'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Advanced","Fortgeschritten","Avancé","Avançado","Avanzado"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('advanced'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Intermediate","Mittelstufe","Intermédiaire","Intermédio","Intermedio"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('intermediate'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Basic","Grundkenntnisse","Basique","Básico","Basico"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('basic'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end

# Web Addresses
Language.all.length.times do |index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('email'), :code => Language.find_by_key(index+1).code, :value => "E-mail", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('homepage'), :code => Language.find_by_key(index+1).code, :value => "Homepage", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('blog'), :code => Language.find_by_key(index+1).code, :value => "Blog", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('xing'), :code => Language.find_by_key(index+1).code, :value => "Xing", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('linkedin'), :code => Language.find_by_key(index+1).code, :value => "LinkedIn", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('facebook'), :code => Language.find_by_key(index+1).code, :value => "Facebook", :context=> "")
  EnumValue.create(:enum_key => EnumKey.find_by_code('twitter'), :code => Language.find_by_key(index+1).code, :value => "Twitter", :context=> "")
end
["Other","Andere","Autre","Outro","Otro"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('other'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end

# Organization Types
["NGO","NRO","ONG","ONG","ONG"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('ngo'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Political","Politisch","Politique","Política","Política"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('political'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Scientific","Wissenschaftlich","Scientifique","Científica","Científica"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('scientific'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Trade Union","Gewerkschaft","Syndicat","Sindicato","Sindicato"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('trade_union'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Social Business","Sozialbetrieb","Activité Sociale","Actividade Social","Actividad Social"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('social_business'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Profit-Driven Business","Gewinnorientierte Firma","Firma à but lucratif","Firma com fins lucrativos","Firma de lucro"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('profit_driven_business'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end

# Tag Contexts
["Affection","Betroffenheit","Affection","Afeição","Afecto"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('affection'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Engagement","Engagement","Engagement","Compromisso","Compromisso"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('engagement'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Expertise","Expertise","Expertise","Especialidade","Peritaje"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('expertise'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Decision Making","Entscheidung","Décision","Decisão","Decisión"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('decision_making'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Field of Work","Arbeitsfeld","Domaine de travail","Domínio de Trabalho","Área de Trabajo"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('field_work'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Field of Activity","Betätigungsfeld","Domaine d'activité","Domínio de Actividade","Área de Actividad"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('field_activity'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Topic","Thema","Sujet","Tópico","Tema"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code('topic'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end

# Statement States
["New","Neu","Neuf","Novo","Nuevo"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('new','StatementState'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Published","Veröffentlicht","Publié","Publicado","Publicado"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('published','StatementState'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end

# Statement States
["New","Neu","Neuf","Novo","Nuevo"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('created','StatementAction'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Edit","Editieren","Éditer","Editar","Editar"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('updated','StatementAction'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Translate","Übersetzen","Traduire","Traduzir","Traducir"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('translated','StatementAction'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Incorporate","Einfügen","Incorporer","Incorporar","Incorporar"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('incorporated','StatementAction'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end


# Collaboration Teams
["Core Team","Ständiges Team","Coeur équipe","Equipa-Núcleo","Equipo Permanente"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('core_team','CollaborationTeam'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Supporters","Unterstützer","Collaborateurs","Colaboradores","Colaboradores"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('supporters','CollaborationTeam'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Alumni","Absolventen","Diplômées","Graduados","Graduados"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('alumni','CollaborationTeam'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Technology Partners","Technologiepartner","Partenaires Tecnologiques","Parceiros Tecnológicos","Colaboradores Tecnológicos"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('technology_partners','CollaborationTeam'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end
["Financial Partners","Finanzpartner","Partenaires Financières","Parceiros Financeiros","Colaboradores Financieros"].each_with_index do |value,index|
  EnumValue.create(:enum_key => EnumKey.find_by_code_and_type('financial_partners','CollaborationTeam'), :code => Language.find_by_key(index+1).code, :value => value, :context=> "")
end