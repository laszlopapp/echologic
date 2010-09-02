class Static::EchonomyController < ApplicationController

  # echonomy - The Values
  def show
    render_static_show :partial => 'show'
  end

  # echonomy - Your-Profit
  def your_profit
    render_static_show :partial => 'your_profit'
  end

  # echonomy - Foundation
  def foundation
    render_static_show :partial => 'foundation'
  end

  # echonomy - Public Property
  def public_property
    render_static_show :partial => 'public_property'
  end
end
