class TaxonomiesController < ApplicationController

  before_filter :authenticate_admin!

  def index
    @taxonomies = Taxonomy.includes(:taxonomy_options).all
  end

  def new
    @taxonomy = Taxonomy.new
  end

  def edit
    @taxonomies = Taxonomy.includes(:taxonomy_options).all
    @taxonomy = Taxonomy.find(params[:id])
  end

  def create
    @taxonomy = Taxonomy.new(params[:taxonomy])

    if @taxonomy.save
      redirect_to taxonomy_taxonomy_options_url(@taxonomy.id), notice: 'Taxonomy was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @taxonomy = Taxonomy.find(params[:id])

    if @taxonomy.update_attributes(params[:taxonomy])
      redirect_to taxonomies_url
    else
      @taxonomies = Taxonomy.includes(:taxonomy_options).all
      render action: "edit"
    end
  end

  def destroy
    @taxonomy = Taxonomy.find(params[:id])
    @taxonomy.destroy

    redirect_to taxonomies_url
  end
end