require 'test_helper'

class DraftingServiceTest < ActiveSupport::TestCase

  context "concerning the drafting service" do
    setup { @drafting_service = DraftingService.instance}
    subject { @drafting_service }
    context "when user supports the first improvement proposal" do
      setup { 
        @user = users(:user)
        @statement = statement_nodes('first-impro-proposal')
        EchoService.instance.supported!(@statement, @user)
      }
      should("then this improvement proposal shall remain tracked") do
        assert @statement.tracked?
      end
    end  

    
    
  end

end