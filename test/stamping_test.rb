$:.unshift(File.dirname(__FILE__))

require 'helpers/unit_test_helper'
require 'models/user'
require 'models/person'
require 'models/post'
require 'models/comment'

class StampingTests < Test::Unit::TestCase  # :nodoc:
  fixtures :users, :people, :posts, :comments

  def setup
    User.stamper = @zeus
    Person.stamper = @delynn
  end

  def test_person_creation_with_stamped_object
    assert_equal @zeus.id, User.stamper
    
    person = Person.create(:name => "David")
    assert_equal @zeus.id, person.maker_id
    assert_equal @zeus.id, person.modifier_id
    assert_equal @zeus, person.maker
    assert_equal @zeus, person.modifier
  end

  def test_person_creation_with_stamped_integer
    User.stamper = 2
    assert_equal 2, User.stamper

    person = Person.create(:name => "Daniel")
    assert_equal @hera.id, person.maker_id
    assert_equal @hera.id,  person.modifier_id
    assert_equal @hera, person.maker
    assert_equal @hera, person.modifier
  end

  def test_post_creation_with_stamped_object
    assert_equal @delynn.id, Person.stamper

    post = Post.create(:title => "Test Post - 1")
    assert_equal @delynn.id, post.maker_id
    assert_equal @delynn.id, post.modifier_id
    assert_equal @delynn, post.maker
    assert_equal @delynn, post.modifier
  end

  def test_post_creation_with_stamped_integer
    Person.stamper = 2
    assert_equal 2, Person.stamper

    post = Post.create(:title => "Test Post - 2")
    assert_equal @nicole.id, post.maker_id
    assert_equal @nicole.id, post.modifier_id
    assert_equal @nicole, post.maker
    assert_equal @nicole, post.modifier
  end

  def test_person_updating_with_stamped_object
    User.stamper = @hera
    assert_equal @hera.id, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus, @delynn.maker
    assert_equal @hera, @delynn.modifier
    assert_equal @zeus.id, @delynn.maker_id
    assert_equal @hera.id, @delynn.modifier_id
  end

  def test_person_updating_with_stamped_integer
    User.stamper = 2
    assert_equal 2, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus.id, @delynn.maker_id
    assert_equal @hera.id, @delynn.modifier_id
    assert_equal @zeus, @delynn.maker
    assert_equal @hera, @delynn.modifier
  end

  def test_post_updating_with_stamped_object
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.maker_id
    assert_equal @nicole.id, @first_post.modifier_id
    assert_equal @delynn, @first_post.maker
    assert_equal @nicole, @first_post.modifier
  end

  def test_post_updating_with_stamped_integer
    Person.stamper = 2
    assert_equal 2, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.maker_id
    assert_equal @nicole.id, @first_post.modifier_id
    assert_equal @delynn, @first_post.maker
    assert_equal @nicole, @first_post.modifier
  end
end