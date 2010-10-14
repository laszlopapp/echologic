class Static::EchocracyController < ApplicationController
    
  %w(show citizens scientists decision_makers organisations).each do |name|
    class_eval %(
      def #{name}
        render_static_show :partial => '#{name}'
      end  
    )
  end
end
