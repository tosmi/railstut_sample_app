require 'test_helper'

class UserIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete',
                      method: :delete
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index only shows activated users" do
    log_in_as(@non_admin)
    get users_path
    # is archer here
    assert_select 'a[href=?]', user_path(@non_admin), text: 'Sterling Archer'
    @non_admin.update_attribute(:activated, false)
    get users_path
    assert_select 'a[href=?]', user_path(@non_admin), text: 'Sterling Archer', :count => 0
    # restore old setting
    @non_admin.update_attribute(:activated, true)
  end

  test "Profile page redirects to root_url if user is not activated" do
    log_in_as(@non_admin)
    @non_admin.update_attribute(:activated, false)
    get user_path(@non_admin)
    assert_redirected_to root_url
    @non_admin.update_attribute(:activated, true)
  end

end
