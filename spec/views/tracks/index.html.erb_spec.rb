require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/index.html.erb" do
  include TracksHelper
  
  before(:each) do
    @event = stub_model(Event,
      :id => 1,
      :title => "Event 1"
    )
    assigns[:event] = @event

    @tracks = [
      stub_model(Track,
        :id => 2,
        :title => "value for title",
        :event_id => @event.id
      ),
      stub_model(Track,
        :id => 3,
        :title => "value for title",
        :event_id => @event.id
      )
    ]
    assigns[:tracks] = @tracks

    @controller.stub!(:get_current_event_and_assignment_status).and_return([@event, :assigned_to_current])

  end

  describe "anonymous" do
    it "should render list" do
      render "/tracks/index.html.erb"
      response.should have_tag("h3", "value for title".to_s, 2)
    end
  end

  describe "admin" do
    fixtures :all

    before(:each) do
      login_as(:aaron)
      render "/tracks/index.html.erb"
    end

    it "should render list" do
      response.should have_tag("h3", "value for title".to_s, 2)
    end

    it "should render new link" do
      save_body
      response.should have_tag("a[href=#{new_track_path}]")
    end

    it "should render edit links" do
      response.should have_tag("a[href=#{edit_track_path(@tracks.first)}]")
    end
  end
end

