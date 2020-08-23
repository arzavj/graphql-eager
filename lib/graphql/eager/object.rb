module GraphQL
  module Eager
    module Object
      def eager_hash(node)
        result = {}
        # If current node has no selections, it must be a scalar value
        return result if node.selections.empty?

        field_type = node.selections[0].owner_type
        sub_fields = field_type.fields

        node.selections.each do |child|
          field_name = Schema::Member::BuildType.camelize(child.name.to_s)
          sub_field = sub_fields[field_name]

          sub_field.eager.each do |key, proc|
            if proc
              result[key] = {proc.call(context) => eager_hash(child)}
            else
              result[key] = eager_hash(child)
            end
          end
        end

        result
      end
    end
  end

  class Schema
    class Object
      prepend Eager::Object
    end
  end
end
