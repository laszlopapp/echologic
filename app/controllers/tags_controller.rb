class TagsController < ApplicationController
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.all

    render_xml(@tags)
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])

    render_xml(@tag)
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    render_xml(@tag)
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to hash_for_tags_url.merge({:action => :show, :id =>@tag.id}) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        render_xml(@tag.errors, :action => 'new', :status => :unprocessable_entity)
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to hash_for_tags_path.merge({:action => :show, :id => @tag.id})}
        format.xml  { head :ok }
      else
        render_xml(@tag.errors, :action => 'edit', :status => :unprocessable_entity)
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
  
  private 
  def render_xml(obj, opts={})
    respond_to do |format|
      if opts[:action]
        format.html { render :action => opts[:action] }
      else
        format.html # new.html.erb
      end
      format.xml  { render :xml => obj, :status => opts[:status] }
    end
  end
end
