module GraphQL
  module Eager
    module Object
      def eager_graph(node)
        graph = {}
        # If current node has no selections, it must be a scalar value
        return graph if node.selections.empty?

        field_type = node.selections[0].owner_type
        sub_fields = field_type.fields

        node.selections.each do |child|
          field_name = Schema::Member::BuildType.camelize(child.name.to_s)
          sub_field = sub_fields[field_name]

          sub_field.eager.each do |key, proc|
            if proc
              graph[key] = {proc.call(context) => eager_graph(child)}
            else
              graph[key] = eager_graph(child)
            end
          end
        end

        graph
      end
    end
  end

  class Schema
    class Object
      prepend Eager::Object
    end
  end
end
