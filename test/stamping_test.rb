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
    assert_equal @zeus.id, person.creatorr_id
    assert_equal @zeus.id, person.updatorr_id
    assert_equal @zeus, person.creatorr
    assert_equal @zeus, person.updatorr
  end

  def test_person_creation_with_stamped_integer
    User.stamper = 2
    assert_equal 2, User.stamper

    person = Person.create(:name => "Daniel")
    assert_equal @hera.id, person.creatorr_id
    assert_equal @hera.id,  person.updatorr_id
    assert_equal @hera, person.creatorr
    assert_equal @hera, person.updatorr
  end

  def test_post_creation_with_stamped_object
    assert_equal @delynn.id, Person.stamper

    post = Post.create(:title => "Test Post - 1")
    assert_equal @delynn.id, post.creatorr_id
    assert_equal @delynn.id, post.updatorr_id
    assert_equal @delynn, post.creatorr
    assert_equal @delynn, post.updatorr
  end

  def test_post_creation_with_stamped_integer
    Person.stamper = 2
    assert_equal 2, Person.stamper

    post = Post.create(:title => "Test Post - 2")
    assert_equal @nicole.id, post.creatorr_id
    assert_equal @nicole.id, post.updatorr_id
    assert_equal @nicole, post.creatorr
    assert_equal @nicole, post.updatorr
  end

  def test_person_updating_with_stamped_object
    User.stamper = @hera
    assert_equal @hera.id, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus, @delynn.creatorr
    assert_equal @hera, @delynn.updatorr
    assert_equal @zeus.id, @delynn.creatorr_id
    assert_equal @hera.id, @delynn.updatorr_id
  end

  def test_person_updating_with_stamped_integer
    User.stamper = 2
    assert_equal 2, User.stamper

    @delynn.name << " Berry"
    @delynn.save
    @delynn.reload
    assert_equal @zeus.id, @delynn.creatorr_id
    assert_equal @hera.id, @delynn.updatorr_id
    assert_equal @zeus, @delynn.creatorr
    assert_equal @hera, @delynn.updatorr
  end

  def test_post_updating_with_stamped_object
    Person.stamper = @nicole
    assert_equal @nicole.id, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.creatorr_id
    assert_equal @nicole.id, @first_post.updatorr_id
    assert_equal @delynn, @first_post.creatorr
    assert_equal @nicole, @first_post.updatorr
  end

  def test_post_updating_with_stamped_integer
    Person.stamper = 2
    assert_equal 2, Person.stamper

    @first_post.title << " - Updated"
    @first_post.save
    @first_post.reload
    assert_equal @delynn.id, @first_post.creatorr_id
    assert_equal @nicole.id, @first_post.updatorr_id
    assert_equal @delynn, @first_post.creatorr
    assert_equal @nicole, @first_post.updatorr
  end
end