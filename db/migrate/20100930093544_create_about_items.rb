class CreateAboutItems < ActiveRecord::Migration
  def self.up
    create_table :about_items do |t|
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.string :name
      t.text :description
      t.integer :collaboration_team_id
      t.integer :index
      t.timestamps
    end
    
    # Descriptions' translations table
    create_table :about_item_translations do |t|
      t.integer :about_item_id
      t.string :locale
      t.text :description
    end
    
    #add new seeds
    CollaborationTeam.enumeration_model_updates_permitted = true
    CollaborationTeam.purge_enumerations_cache
    %w(core_team supporters alumni technology_partners financial_partners).each_with_index do |code, index|
      CollaborationTeam.create!(:code => code, :key => index+1, :description => "collaboration_team")
    end
    CollaborationTeam.enumeration_model_updates_permitted = false
    
    EnumValue.enumeration_model_updates_permitted = true
    ["Core Team","Ständiges Team","Coeur équipe","Equipa-Núcleo","Equipo Permanente"].each_with_index do |value,index|
      EnumValue.create!(:enum_key => EnumKey.find_by_code_and_type('core_team','CollaborationTeam'), :code => EnumKey.find_by_type_and_key('Language',index+1).code, :value => value, :context=> "")
    end
    ["Supporters","Unterstützer","Collaborateurs","Colaboradores","Colaboradores"].each_with_index do |value,index|
      EnumValue.create!(:enum_key => EnumKey.find_by_code_and_type('supporters','CollaborationTeam'), :code => EnumKey.find_by_type_and_key('Language',index+1).code, :value => value, :context=> "")
    end
    ["Alumni","Absolventen","Diplômées","Graduados","Graduados"].each_with_index do |value,index|
      EnumValue.create!(:enum_key => EnumKey.find_by_code_and_type('alumni','CollaborationTeam'), :code => EnumKey.find_by_type_and_key('Language',index+1).code, :value => value, :context=> "")
    end
    ["Technology Partners","Technologiepartner","Partenaires Tecnologiques","Parceiros Tecnológicos","Colaboradores Tecnológicos"].each_with_index do |value,index|
      EnumValue.create!(:enum_key => EnumKey.find_by_code_and_type('technology_partners','CollaborationTeam'), :code => EnumKey.find_by_type_and_key('Language',index+1).code, :value => value, :context=> "")
    end
    ["Financial Partners","Finanzpartner","Partenaires Financières","Parceiros Financeiros","Colaboradores Financieros"].each_with_index do |value,index|
      EnumValue.create!(:enum_key => EnumKey.find_by_code_and_type('financial_partners','CollaborationTeam'), :code => EnumKey.find_by_type_and_key('Language',index+1).code, :value => value, :context=> "")
    end
    EnumValue.purge_enumerations_cache
    EnumValue.enumeration_model_updates_permitted = false
  end

  def self.down
    drop_table :about_items
    drop_table :about_item_translations
    EnumValue.enumeration_model_updates_permitted = true
    CollaborationTeam.all.each do |c|
      EnumValue.destroy_all({:enum_key_id => c.id})
    end
    EnumValue.purge_enumerations_cache
    EnumValue.enumeration_model_updates_permitted = false
    CollaborationTeam.enumeration_model_updates_permitted = true
    CollaborationTeam.destroy_all
    CollaborationTeam.purge_enumerations_cache
    CollaborationTeam.enumeration_model_updates_permitted = false
  end
end
