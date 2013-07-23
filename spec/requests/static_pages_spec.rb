require 'spec_helper'

describe "Static pages" do

  subject { page }

  it "should have the right links on the layout" do
    visit root_path
    check_link_title("About", 'About Us')
    check_link_title("Help", 'Help')
    check_link_title("Contact", 'Contact')
    click_link "Home"
    check_link_title("Sign up now!", 'Sign up')
    check_link_title("sample app", '')
  end

  shared_examples_for "all static pages" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        50.times { FactoryGirl.create(:micropost, user: user) }
        sign_in user
        visit root_path
      end

      after { user.microposts.delete_all }

      describe "feed" do

        it "should render the user's feed" do
          user.feed.paginate(page: 1).each do |item|
            expect(page).to have_selector("li##{item.id}", text: item.content)
          end
        end

        it "should not render delete links for microposts not created by the user" do
          others_microposts = []
          others_microposts ||= user.feed.find { |micropost| micropost.user != user }
          others_microposts.each do |micropost|
            expect(page).not_to have_selector("li##{micropost.id}", text: "delete") 
          end
        end

        it "should render the micropost's count" do
          expect(page).to have_content(user.feed.count)
        end

        describe "follower/following counts" do
          let(:other_user) { FactoryGirl.create(:user) }
          before do
            other_user.follow!(user)
            visit root_path
          end

          it { should have_link("0 following", href: following_user_path(user)) }
          it { should have_link("1 followers", href: followers_user_path(user)) }
        end
      end

      describe "pagination" do

        it { should have_selector('div.pagination') }

        it "should list each micropost" do
          user.microposts.paginate(page: 1).each do |micropost|
            expect(page).to have_selector('li', text: micropost.content)
          end
        end
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end
end