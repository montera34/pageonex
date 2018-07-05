class TaxonomyOptionsController < ApplicationController

  before_filter :authenticate_admin!
  before_filter :load_taxonomy, only: [:index, :destroy, :create, :edit, :update]
  before_filter :load_taxonomy_option, only: [:destroy, :edit, :update]
  before_filter :load_taxonomy_options, only: [:index, :edit]

  def index
  end

  def edit
  end

  def create
    @taxonomy_option = @taxonomy.taxonomy_options.new(params[:taxonomy_option])

    if @taxonomy_option.save
      redirect_to taxonomy_taxonomy_options_url(@taxonomy)
    else
      redirect_to taxonomy_taxonomy_options_url(@taxonomy), alert: "Error: #{@taxonomy_option.errors[:value].first}"
    end
  end

  def update
    if @taxonomy_option.update_attributes(params[:taxonomy_option])
      redirect_to taxonomy_taxonomy_options_url(@taxonomy)
    else
      load_taxonomy_options
      render action: "edit"
    end
  end

  def destroy
    @taxonomy_option.destroy

    redirect_to taxonomy_taxonomy_options_url(@taxonomy)
  end

  private
    def load_taxonomy
      @taxonomy = Taxonomy.find(params[:taxonomy_id])
    end

    def load_taxonomy_option
      @taxonomy_option = @taxonomy.taxonomy_options.find(params[:id])
    end

    def load_taxonomy_options
      @taxonomy_options = @taxonomy.taxonomy_options
    end
end