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
Language.enumeration_model_updates_permitted = true
Language.purge_enumerations_cache
%w(en de fr pt es).each_with_index do |code, index|
  Language.create(:code => code, :key => index+1, :description => "language")
end
Language.enumeration_model_updates_permitted = false

# LANGUAGE LEVELS
LanguageLevel.enumeration_model_updates_permitted = true
LanguageLevel.purge_enumerations_cache
%w(mother_tongue advanced intermediate basic).each_with_index do |code, index|
  LanguageLevel.create(:code => code, :key => index+1, :description => "language_level")
end
LanguageLevel.enumeration_model_updates_permitted = false

# WEB ADDRESSES
WebAddressType.enumeration_model_updates_permitted = true
WebAddressType.purge_enumerations_cache
%w(email homepage blog xing linkedin facebook twitter).each_with_index do |code, index|
  WebAddressType.create(:code => code, :key => index+1, :description => "web_address_type")
end
WebAddressType.create(:code => 'other', :key => 99, :description => "web_address_type")
WebAddressType.enumeration_model_updates_permitted = false

# ORGANISATION TYPES
OrganisationType.enumeration_model_updates_permitted = true
OrganisationType.purge_enumerations_cache
%w(ngo political scientific trade_union social_business profit_driven_business).each_with_index do |code, index|
  OrganisationType.create(:code => code, :key => index+1, :description => "organisation_type")
end
OrganisationType.enumeration_model_updates_permitted = false

# TAG CONTEXTS
TagContext.enumeration_model_updates_permitted = true
TagContext.purge_enumerations_cache
%w(affection engagement expertise decision_making field_work field_activity topic).each_with_index do |code, index|
  TagContext.create(:code => code, :key => index+1, :description => "tag_context")
end
TagContext.enumeration_model_updates_permitted = false

# STATEMENT STATES
StatementState.enumeration_model_updates_permitted = true
StatementState.purge_enumerations_cache
%w(new published).each_with_index do |code, index|
  StatementState.create(:code => code, :key => index+1, :description => "statement_state")
end
StatementState.enumeration_model_updates_permitted = false

# STATEMENT DOCUMENT ACTIONS
StatementAction.enumeration_model_updates_permitted = true
StatementAction.purge_enumerations_cache
%w(created updated translated incorporated).each_with_index do |code, index|
  StatementAction.create(:code => code, :key => index+1, :description => "statement_action")
end
StatementAction.enumeration_model_updates_permitted = false

# ABOUT CATEGORIES
AboutCategory.enumeration_model_updates_permitted = true
AboutCategory.purge_enumerations_cache
%w(core_team supporters translators interns alumni technology_partners financial_partners strategic_partners thematic_partners).each_with_index do |code, index|
  AboutCategory.create(:code => code, :key => index+1, :description => "about_category")
end
AboutCategory.enumeration_model_updates_permitted = false


#################
#  ENUM VALUES  #
#################

EnumValue.enumeration_model_updates_permitted = true
EnumValue.purge_enumerations_cache

# Languages
["English","Englisch","Ingles","Inglês","Inglés"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('en'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context => "")
end
["German","Deutsch","Aleman","Alemão","Alemán"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('de'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context => "")
end
["French","Französisch","Français","Francês","Francés"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('fr'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context => "")
end
["Portuguese","Portugiesisch","Portugais","Português","Portugués"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('pt'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context => "")
end
["Spanish","Spanisch","Espagnol","Espanhol","Español"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('es'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context => "")
end

# Language Levels
["Mother Tongue","Muttersprache","Langue Maternelle","Língua Materna","Lengua Materna"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('mother_tongue'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context=> "")
end
["Advanced","Fortgeschritten","Avancé","Avançado","Avanzado"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('advanced'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context=> "")
end
["Intermediate","Mittelstufe","Intermédiaire","Intermédio","Intermedio"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('intermediate'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context=> "")
end
["Basic","Grundkenntnisse","Basique","Básico","Basico"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('basic'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context=> "")
end

# Web Addresses
Language.all.length.times do |index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('email'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "E-mail", :context=> "")
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('homepage'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "Homepage", :context=> "")
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('blog'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "Blog", :context=> "")
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('xing'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "Xing", :context=> "")
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('linkedin'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "LinkedIn", :context=> "")
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('facebook'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "Facebook", :context=> "")
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('twitter'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => "Twitter", :context=> "")
end
["Other","Andere","Autre","Outro","Otro"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('other'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context=> "")
end

# Organization Types
["NGO","NRO","ONG","ONG","ONG"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('ngo'),
                              :code => EnumKey.find_by_type_and_key('Language', index+1).code,
                              :value => value, :context=> "")
end
["Political","Politisch","Politique","Política","Política"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('political'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Scientific","Wissenschaftlich","Scientifique","Científica","Científica"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('scientific'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Trade Union","Gewerkschaft","Syndicat","Sindicato","Sindicato"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('trade_union'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Social Business","Social Business","Social Business","Social Business","Social Business"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('social_business'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Profit-Driven Business","Gewinnorientierte Firma","Firma à but lucratif",
 "Firma com fins lucrativos","Firma de lucro"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('profit_driven_business'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end

# Tag Contexts
["Affection","Betroffenheit","Affection","Afeição","Afecto"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('affection'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Engagement","Engagement","Engagement","Compromisso","Compromisso"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('engagement'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Expertise","Expertise","Expertise","Especialidade","Peritaje"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('expertise'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Decision Making","Entscheidung","Décision","Decisão","Decisión"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('decision_making'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Field of Work","Arbeitsfeld","Domaine de travail",
 "Domínio de Trabalho","Área de Trabajo"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('field_work'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Field of Activity","Betätigungsfeld","Domaine d'activité",
 "Domínio de Actividade","Área de Actividad"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('field_activity'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Topic","Thema","Sujet","Tópico","Tema"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code('topic'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end

# Statement States
["New","Neu","Neuf","Novo","Nuevo"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('new','StatementState'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Published","Veröffentlicht","Publié","Publicado","Publicado"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('published','StatementState'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end

# Statement States
["New","Neu","Neuf","Novo","Nuevo"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('created','StatementAction'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Edit","Editieren","Éditer","Editar","Editar"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('updated','StatementAction'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Translate","Übersetzen","Traduire","Traduzir","Traducir"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('translated','StatementAction'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Incorporate","Einfügen","Incorporer","Incorporar","Incorporar"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('incorporated','StatementAction'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end


# About Items (order of values: EN, DE, FR, PT, ES)
["Core Team","Kernteam","Coeur équipe","Equipa-Núcleo","Equipo Núcleo"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('core_team','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["External Staff & Supporters","Externe Mitarbeiter & Unterstützer","Personnel Externe & Collaborateurs",
 "Pessoal Externo & Colaboradores","Personal Externo & Colaboradores"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('supporters','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Translators","Übersetzer","Traducteurs","Tradutores","Traductores"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('translators','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Interns","Praktikanten","Stagiaires","Estagiários","Becarios"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('interns','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Alumni","Alumni","Alumni","Alumni","Alumni"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('alumni','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Technology Partners","Technologiepartner","Les partenaires tecnologiques",
 "Parceiros Tecnológicos","Colaboradores Tecnológicos"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('technology_partners','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Financial Partners","Finanzpartner","Les partenaires financières",
 "Parceiros Financeiros","Colaboradores Financieros"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('financial_partners','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Strategic Partners","Strategische Partner","Les partenaires stratégiques",
 "Parceiros Estratégicos","Colaboradores Estratégicos"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('strategic_partners','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end
["Thematic Partners","Thematische Partner","Les partenaires thématiques",
 "Parceiros Temáticos","Colaboradores Temáticas"].each_with_index do |value,index|
  EnumValue.create_or_update!(:enum_key => EnumKey.find_by_code_and_type('thematic_partners','AboutCategory'),
                              :code => EnumKey.find_by_type_and_key('Language',index+1).code,
                              :value => value, :context=> "")
end


EnumValue.enumeration_model_updates_permitted = false