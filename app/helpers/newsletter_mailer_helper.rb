module NewsletterMailerHelper

  # Returns the full URL to the given path.
  def full_url(path)
    'http://' + ECHO_HOST + path
  end

end
