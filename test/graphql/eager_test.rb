require 'test_helper'

class GraphQL::EagerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GraphQL::Eager::VERSION
  end

  DATA = [
    OpenStruct.new(
      id: 1,
      title: "Title 1",
      comments: [
        OpenStruct.new(
          content: "Comment 1",
          author: OpenStruct.new(id: 1, first_name: "First 1", last_name: "Last 1"),
        ),
        OpenStruct.new(
          content: "Comment 2",
          author: OpenStruct.new(id: 2, first_name: "First 2", last_name: "Last 2"),
        ),
      ],
    ),
  ]

  def DATA.find_by_id(id)
    DATA.find {|b| b.id == id}
  end

  class AuthorType < GraphQL::Schema::Object
    description "An author"

    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
  end

  class CommentType < GraphQL::Schema::Object
    description "A comment"

    field :id, ID, null: false
    field :content, String, null: false

    field(
      :author,
      AuthorType,
      null: false,
      eager: {author: nil},
    )
  end

  class PostType < GraphQL::Schema::Object
    description "A blog post"

    field :id, ID, null: false
    field :title, String, null: false

    field(
      :comments,
      [CommentType],
      null: true,
      description: "The comments on this post.",
      eager: {comments: nil},
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

  def test_it_does_something_useful
    query_string = <<-GRAPHQL
      {
        post(id: 1) {
          id
          title
          comments {
            id
            content
            author {
              id
              firstName
              lastName
            }
          }
        }
      }
    GRAPHQL

    context = {}
    result = Schema.execute(query_string, context: context)
    assert_equal({comments: {author: {}}}, context[:eager_hash])
  end
end
