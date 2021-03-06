require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/proposals/show.html.erb" do
  before do
    @controller.stub!('can_edit?').and_return(false)
  end
  
  before :each do
    @user = Factory :user
    @event = Factory :populated_event, :proposal_status_published => false
    @proposal = proposal_for_event(@event, :users => [@user])

    @controller.stub!(:schedule_visible? => true)
  end
  
  %w[accepted confirmed rejected junk].each do |status|
    it "should not show the status for #{status} proposals if statuses are not published" do
      @event.proposal_status_published = false
      @proposal.status = status
      
      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    
      render "/proposals/show.html.erb"
      response.should_not have_tag(".proposal-status #{status}")
    end
  end
  
  %w[accepted rejected junk].each do |status|
    it "should should not show the status for #{status} proposals even if statuses are published" do
      @event.proposal_status_published = true
      @proposal.status = status
      
      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    
      render "/proposals/show.html.erb"
      response.should_not have_tag(".proposal-status #{status}")
    end
  end

  describe "with confirmed proposal for event that publishes status" do
    before :each do
      @event.proposal_status_published = true
      @proposal.status = 'confirmed'
      @proposal.start_time = nil
      @proposal.room = nil

      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    end

    it "should show the proposal status for a confirmed proposal" do
      render "/proposals/show.html.erb"
      response.should have_tag(".proposal-status")
      response.should_not have_tag(".proposal-scheduling")
      response.should_not have_tag(".proposal-room")
    end

    it "should show session time if set" do
      @proposal.start_time = Time.now

      render "/proposals/show.html.erb"
      response.should have_tag(".proposal-scheduling")
      response.should_not have_tag(".proposal-room")
    end

    it "should show session time and location if both set" do
      @proposal.start_time = Time.now
      @proposal.room = @event.rooms.first

      render "/proposals/show.html.erb"
      response.should have_tag(".proposal-scheduling")
      response.should have_tag(".proposal-room")
    end
  end

  it "should only show proposals in the speaker's bio that are for this event and its family" do
    user = Factory :user
    parent = Factory :populated_event, :proposal_status_published => true
    event  = Factory :populated_event, :proposal_status_published => true, :parent => parent
    child  = Factory :populated_event, :proposal_status_published => true, :parent => event
    other  = Factory :populated_event, :proposal_status_published => true
    event_proposal  = session_for_event event,  :users => [user]
    child_proposal  = session_for_event child,  :users => [user]
    other_proposal  = session_for_event other,  :users => [user]
    parent_proposal = session_for_event parent, :users => [user]
    event.reload

    assigns[:event] = event
    assigns[:proposal] = event_proposal
    assigns[:kind] = :proposal
    render "/proposals/show.html.erb"

    response.should have_tag(".session_info a[href=?]", session_path(event_proposal))
    response.should have_tag(".session_info a[href=?]", session_path(child_proposal))
    response.should have_tag(".session_info a[href=?]", session_path(parent_proposal))
    response.should_not have_tag(".session_info a[href=?]", session_path(other_proposal))
  end
end

