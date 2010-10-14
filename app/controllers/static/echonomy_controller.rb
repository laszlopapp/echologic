class Static::EchonomyController < ApplicationController
  %w(show your_profit foundation public_property).each do |name|
    class_eval %(
      def #{name}
        render_static_show :partial => '#{name}'
      end  
    )
  end
end
