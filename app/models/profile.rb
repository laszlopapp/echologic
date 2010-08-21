class Profile < ActiveRecord::Base

  # Constants
  COMPLETENESS_THRESHOLD = 0.42

  # Every profile has to belong to a user.
  belongs_to :user
  has_many :web_addresses, :through => :user
  has_many :memberships,  :through => :user
  has_many :spoken_languages, :through => :user

  delegate :email, :email=, :affection_tags, :expertise_tags, :engagement_tags, :decision_making_tags, :to => :user


  validates_presence_of :user_id
  validates_length_of :about_me, :maximum => 1024, :allow_nil => true
  validates_length_of :motivation, :maximum => 1024, :allow_nil => true

  # To calculate profile completeness
  include ProfileExtension::Completeness

  # TODO: do we need this ?
  named_scope :by_last_name_first_name_id,
              :include => :user,
              :order => 'CASE WHEN last_name IS NULL OR last_name="" THEN 1 ELSE 0 END, last_name, first_name, user.id asc'

  # There are two kind of people in the world..
  @@gender = {
    false => I18n.t('users.profile.gender.male'),
    true  => I18n.t('users.profile.gender.female')
  }

  # Access for the class variable
  def self.gender
    @@gender
  end

  # Returns the localized gender
  def localized_gender
    @@gender[female] || '' # I18n.t('application.general.undefined')
  end

  # Handle attached user picture through paperclip plugin
  has_attached_file :avatar, :styles => { :big => "128x>", :small => "x45>" },
                    :default_url => "/images/default_:style_avatar.png"
  validates_attachment_size :avatar, :less_than => 5.megabytes
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png']
  # paperclip callback, used to recalculate completeness when uploading an avatar
  after_avatar_post_process :calculate_completeness

  # Return the full name of the user composed of first- and lastname
  def full_name
    [first_name, last_name].select { |s| s.try(:any?) }.join(' ')
  end

  # Return the formatted location of the user
  # TODO conditions in compact form?
  #  - something like this?: [city, country].select{|s|s.try(:any?)}.join(', ')
  def location
    [city, country].select { |s| s.try(:any?) }.join(', ')
  end

  # Return the first membership. If none is set return empty-string.
  def first_membership
    return "" if memberships.blank?
    "#{memberships.first.organisation} - #{memberships.first.position}"
  end

  # Self written SQL for querying profiles in echo Connect
  def self.search_profiles(competence, search_term)

    # Building the select clause
    select_clause = <<-END
      select distinct p.*, u.email
      from
        profiles p
        LEFT JOIN users u        ON u.id = p.user_id
        LEFT JOIN memberships m  ON u.id = m.user_id
        LEFT JOIN tao_tags tt    ON (u.id = tt.tao_id and tt.tao_type = 'User')
        LEFT JOIN tags t         ON t.id = tt.tag_id
      where
    END

    # Building the where clause
    # Filtering active users
    and_conditions = ["u.active = 1"]

    # Searching for different competences
    if (competence.blank?)
      # General search
      searched_fields =
        %w(p.first_name p.last_name p.city p.country p.about_me p.motivation u.email t.value m.position m.organisation)
    else
      # Search for a certain competence area
      searched_fields =
        %w(p.first_name p.last_name p.city p.country t.value)
      and_conditions << "tt.context_id = #{competence}"
    end
    search_conditions = searched_fields.map{|field|"#{field} LIKE ?"}.join(" OR ")
    and_conditions << "(#{search_conditions})"
    where_clause = and_conditions.join(" AND ")

    # Building the order clause
    order_clause = " order by
      CASE WHEN p.completeness >= #{COMPLETENESS_THRESHOLD} THEN 0 ELSE 1 END,
      CASE WHEN p.last_name IS NULL OR p.last_name='' THEN 1 ELSE 0 END,
      p.last_name, p.first_name, u.id asc;"

    # Composing the query and substituting the values
    query = select_clause + where_clause + order_clause
    value = "%#{search_term}%"
    conditions = [query, *([value] * searched_fields.size)]

    # Executing the query
    profiles = find_by_sql(conditions)
  end
end
