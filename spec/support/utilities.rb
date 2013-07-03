include ApplicationHelper

def valid_signin(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

def check_link_title(link, title)
  click_link link
  expect(page).to have_title(full_title(title))
end

def test_static_page(path, heading, page_title)
  before { visit path }
  let(:heading)    { heading }
  let(:page_title) { page_title }

  it_should_behave_like "all static pages"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end