class Static::EchonomyController < ApplicationController

  # echonomy - The Values
  def show
    render_static :partial => 'show'
  end

  # echonomy - Your-Profit
  def your_profit
    render_static :partial => 'your_profit'
  end

  # echonomy - Foundation
  def foundation
    render_static :partial => 'foundation'
  end

  # echonomy - Public Property
  def public_property
    render_static :partial => 'public_property'
  end
end
