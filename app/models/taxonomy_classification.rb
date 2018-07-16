class TaxonomyClassification < ActiveRecord::Base
  belongs_to :highlighted_area
  belongs_to :taxonomy_option

  delegate :taxonomy, to: :taxonomy_option
  delegate :code, to: :highlighted_area

  validate :taxonomy_in_thread

  def taxonomy_in_thread
    thread = Threadx.find(code.threadx_id)
    unless thread.taxonomy_ids.include?(taxonomy_option.taxonomy_id)
      errors.add(:taxonomy_option_id, 'Taxonomy not allowed in this thread')
    end
  end
end
