class SortableController < ApplicationController
  #
  # post /sortable/reorder, rails_sortable: [{ klass: "Item", id: "3" }, { klass: "Item", id: "2" }, { klass: "Item", id: "1" }]
  #
  def reorder
    ActiveRecord::Base.transaction do
      params['rails_sortable'].each_with_index do |klass_to_id, new_sort|
        model = find_model(klass_to_id)
        model = model.first if model.is_a?(JsonApiClient::ResultSet)
        if model.respond_to?(:read_attribute)
          current_sort = model.read_attribute(model.class.sort_attribute)
        else
          current_sort = model.send(model.class.sort_attribute)
        end
        
        model.update_sort!(new_sort) if current_sort != new_sort
      end
    end

    head :ok
  end

private

  def find_model(klass_to_id)
    klass, id = klass_to_id.values_at('klass', 'id')
    klass.constantize.find(id)
  end
end
