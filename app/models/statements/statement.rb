class Statement < ActiveRecord::Base
  has_many :statement_nodes
  has_many :statement_documents, :dependent => :destroy
  validates_associated :statement_documents

  has_many :statement_histories, :source => :statement_histories

  # Handle attached statement image through paperclip plugin
  has_attached_file :image, :styles => { :big => "800x600>", :medium => "170x125>", :small => "x45>" },
                    :default_url => "/images/default_:style_image.png"
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png']

  def authors
    statement_histories.select{|sh|original_language.eql?(sh.language)}.map{|s|s.author}
  end

  enum :original_language, :enum_name => :languages

  named_scope :find_by_title, lambda {|value|
            { :include => :statement_documents, :conditions => ['statement_documents.title LIKE ? and statement_documents.current = 1', "%#{value}%"] } }


  #
  # Returns the current statement document in the given language.
  #
  def document_in_language(language)
    self.statement_documents.find(:first, :conditions => ["language_id = ? and current = 1", language.id])
  end
end
