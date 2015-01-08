require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow a user do" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, followed_id: @other_user.id
    end
    @user.unfollow(@other_user)
    assert_difference '@user.following.count', 1 do
      xhr :post, relationships_path, followed_id: @other_user.id
    end
  end

  test "should unfollow a user do" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), relationship_id: relationship.id
    end
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference '@user.following.count', -1 do
      xhr :delete, relationship_path(relationship), relationship_id: relationship.id
    end
  end
end
