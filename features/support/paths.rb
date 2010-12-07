module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the profile/
      my_profile_path
    when /my settings/
      settings_path
    when /the start page/
      root_path
    when /the connect page/
      connect_path
    when /the connect roadmap/
      connect_roadmap_path
    when /the welcome page/
      welcome_path
    when /the reports page/
      reports_path
    when /^create a discussion$/
      new_discussion_path
    when /^the discussion$/
      discussion_path(@discussion)
    when /^the proposal$/
      proposal_path(@proposal)
    when /^the improvement proposal$/
      improvement_proposal_path(@improvement_proposal)
    when /^the first discussion$/
      discussion_path(Discussion.first)
    when /^the discussions first proposal/
      proposal_path(@proposal)
    when /discuss index/i
      discuss_search_url
    when /my issues/i
      my_discussions_url
    when /discuss featured/i
      discuss_featured_path
    when /discuss search/i
      discuss_search_path
    when /the proposal/
      raise [@proposal.inspect,@proposal.parent.inspect].join('\n')
      proposal_path(@proposal)
    when /the activation page/
      register_url(@user.perishable_token)
    when /the edit password page/
      edit_password_reset_url(@user.perishable_token)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
