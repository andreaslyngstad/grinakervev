class PublicController < ApplicationController
  skip_before_filter :login_required, :recent_posts, :recent_videos, :recent_guides
  before_filter :set_all_categories, :set_all_levels, 
                :instantiate_controller_and_action_names, :get_pages_for_tabs, :get_sub_tabs, :get_tags
 
  layout "public"
  
  def index 
    @page = Page.find_by_name(params[:name], :include => [:parent])
    if @page.nil?
      redirect_to(:action => "start")
    end
    @post = Post.first
    DataFile.all.each do |img|
      if img.use == true 
        @image = img.photo.url 
      end
    end
    
  end
  
  def start
    
  end
  def tag
    @tag = Tag.find(params[:id])
    @posts = Post.find_tagged_with(@tag, :include => [:author, :comments],
    :order => "posts.created_at DESC")
    render(:action => 'blogg')
    
  end
  
  def blogg
    @posts = Post.search(params[:search])
    respond_to do |format|
      format.html
      format.rss
    end
  end
  
  def view_post
    @post = Post.find(params[:id], :include => [:author, :categories, :approved_comments])
    render(:template => 'shared/view_post')
  end
  
  def add_comment
    @comment = Comment.new(params[:comment])
    @post = Post.find(params[:id])
    if simple_captcha_valid?
    
    @comment.post = @post
    @comment.status = "nye"
    if @comment.save
      flash[:notice] = "Du har lagt til en kommentar."
      redirect_to(:action => "view_post", :id => @post.id)
    else
      flash[:error] = "Obs! Du skrive navn, gyldig epost og en kommentar. Prøv igjen."
      render(:template => 'shared/view_post')
    end
  else
    
   flash[:error] = "Du skrev ikke koden riktig. Prøv igjen"
   render(:template => 'shared/view_post')
    end
   
  end
  
   def category
    @posts = Post.find(:all, :include => [:author, :categories], 
    :conditions => ["status = 'Offentlig' AND categories.id = ?", params[:id]], 
    :order => "posts.created_at DESC")
    render(:action => 'blogg')
  end
   
  
  
end
