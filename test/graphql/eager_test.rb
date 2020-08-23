require 'test_helper'

class GraphQL::EagerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GraphQL::Eager::VERSION
  end

  class AuthorType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
  end

  class CommentType < GraphQL::Schema::Object
    description 'A comment'

    field :id, ID, null: false
    field :text, String, null: false

    field(
      :author,
      AuthorType,
      null: false,
      eager: {author: nil},
    )
  end

  class PostType < GraphQL::Schema::Object
    description 'A blog post'

    field :id, ID, null: false
    field :title, String, null: false

    field(
      :comments,
      [CommentType],
      null: true,
      description: 'The comments on this post.',
      eager: {
        all_list_entries: (proc do |context|
          user_id = context[:user_id]

          (proc do |ds|
            search_terms = {
              lists_entries__user_id: user_id,
            }
            ds.where(search_terms)
          end)
        end),
      },
    )
  end

  class QueryType < GraphQL::Schema::Object
    description 'The query root of this schema'

    # First describe the field signature:
    field :post, PostType, null: true, extras: [:lookahead] do
      description 'Find a post by ID'
      argument :id, ID, required: true
    end

    # Then provide an implementation:
    def post(id:, lookahead:)
      puts eager_graph(lookahead)
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
            author {
              id
              firstName
              lastName
            }
          }
        }
      }
    GRAPHQL
    Schema.execute(query_string, context: {user_id: 1})
    assert false
  end
end
