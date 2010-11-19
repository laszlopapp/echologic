class DiscussionsController < StatementsController
  
  # Shows an add discussion teaser page
  #
  # Method:   GET
  # Params:   type: string
  # Response: HTTP or JS
  #
  def add_discussion
    add('discussion')
  end

  # Shows an add proposal teaser page
  #
  # Method:   GET
  # Params:   type: string
  # Response: HTTP or JS
  #
  def add_proposal
    add('proposal')
  end

end
