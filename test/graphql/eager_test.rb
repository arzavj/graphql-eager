require 'test_helper'

class GraphQL::EagerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GraphQL::Eager::VERSION
  end

  DATA = [
    OpenStruct.new(
      id: 1,
      comments: [
        OpenStruct.new(id: 1, author: OpenStruct.new(id: 1)),
        OpenStruct.new(id: 2, author: OpenStruct.new(id: 2)),
      ],
    ),
  ]

  def DATA.find_by_id(id)
    DATA.find {|b| b.id == id}
  end

  class PersonType < GraphQL::Schema::Object
    description "A person"

    field :id, ID, null: false
  end

  class UpvoteType < GraphQL::Schema::Object
    description "An upvote"

    field :id, ID, null: false
    field :upvoter, PersonType, null: false, eager: :upvoter
  end

  class CommentType < GraphQL::Schema::Object
    description "A comment"

    field :id, ID, null: false

    field(
      :author,
      PersonType,
      null: false,
      eager: {author: nil},
    )

    field(
      :upvotes,
      [UpvoteType],
      null: false,
      eager: {
        upvote: {
          upvoter: (proc do |context|
            user_id = context[:user_id]
            (proc do |ds|
              ds.where(user_id: user_id)
            end)
          end)
        },
      },
    )

    field(
      :num_upvotes,
      Integer,
      null: false,
      eager: :upvotes,
    )
  end

  class PostType < GraphQL::Schema::Object
    description "A blog post"

    field :id, ID, null: false

    field(
      :comments,
      [CommentType],
      null: true,
      description: "The comments on this post.",
      eager: {comments: nil},
    )

    field(
      :total_upvotes,
      Integer,
      null: false,
      eager: {comments: :upvotes}
    )
  end

  class QueryType < GraphQL::Schema::Object
    description "The query root of this schema"

    # First describe the field signature:
    field :post, PostType, null: true, extras: [:lookahead] do
      description "Find a post by ID"
      argument :id, ID, required: true
    end

    # Then provide an implementation:
    def post(id:, lookahead:)
      context[:eager_hash] = eager_hash(lookahead)
      DATA.find_by_id(id)
    end
  end

  class Schema < GraphQL::Schema
    query QueryType
  end

  def assert_eager_hash(query_string, expected_eager_hash)
    context = {}
    Schema.execute(query_string, context: context)
    assert_equal expected_eager_hash, context[:eager_hash]
  end

  def test_basic
    query_string = <<-GRAPHQL
      {
        post(id: 1) {
          id
          comments {
            id
            author {
              id
            }
          }
        }
      }
    GRAPHQL

    assert_eager_hash(query_string, {comments: {author: nil}})
  end

  def test_only_eager_load_requested_fields
    query_string = <<-GRAPHQL
      {
        post(id: 1) {
          id
          comments {
            id
          }
        }
      }
    GRAPHQL

    assert_eager_hash(query_string, {comments: {}})

    query_string = <<-GRAPHQL
      {
        post(id: 1) {
          id
        }
      }
    GRAPHQL

    assert_eager_hash(query_string, {})
  end

  def test_
end
