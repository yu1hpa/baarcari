require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'digest/sha2'
require 'cgi'
require 'securerandom'

set :environment, :production
set :session_store, Rack::Session::Cookie

use Rack::Session::Cookie,
  :key => 'rack.session',
  :expire_after => 60,
  :secret => Digest::SHA256.hexdigest(rand.to_s)

class User < ActiveRecord::Base
end

class ExhibitionObjs < ActiveRecord::Base
end

class Applicant < ActiveRecord::Base
end

class App < Sinatra::Base
  enable :sessions
  ActiveRecord.default_timezone = :local

  # ページネーション最大件数
  LIMIT = 5

  FILTER_ME = "FILTER_ME"
  FILETER_OTHER = "FILTER_OTHER"

  get '/' do
    if session[:user_id] == nil
      @exobj = disp_exobjs()
      erb :index
    else
      @uid = session[:user_id]

      # ページネーション
      begin
        page = params[:page] == nil ? 0 : params[:page].to_i - 1
      rescue
        page = 0
      end

      @exobj = disp_exobjs_with_page(page, FILETER_OTHER)
      if session[:searched_result] != nil
        @searched_result = session[:searched_result]
      else
        @searched_result = ""
      end
      erb :index4login
    end
  end
  
  get '/login' do
    @notfounduser = session[:notfounduser]
    erb :login
  end
  
  get '/logout' do
    session.clear
    redirect '/'
  end
  
  get '/signup' do
    @errormsg = session[:errormsg]
    erb :signup
  end

  post '/signup' do
    a = User.all
    maxid = 0
    a.each do |ai|
      if ai.id > maxid
        maxid = ai.id
      end
      if ai.username == params[:username]
        session[:errormsg] = "既に登録されているユーザー名です"
        redirect '/signup'
      end
    end

    begin
      u = User.new
      u.id = maxid + 1
      u.user_id = SecureRandom.uuid
      u.username = params[:username]
      u.passwd = Digest::SHA256.hexdigest(params[:passwd])
      u.email = params[:email]
      u.save
    rescue => e
      p e
    end

    redirect '/login'
  end
 
  get '/users/:user_id' do
    if session[:user_id] == nil
      redirect '/login'
    end

    begin
      user_id = params[:user_id]
      @uid = params[:user_id]
      if is_uuid(params[:user_id])
        u = User.find_by(user_id: user_id)
        @username = u.username
      end
      # ページネーションをおこなわないので使用しない
      # @exobj_items = disp_exobjs_with_page(FILTER_ME)
      @exobj_items = disp_exobjs_with_userid(session[:user_id])
    rescue => e
      p e
    end
    erb :profile
  end
  
  post '/auth' do
    name = params[:username]
    passwd = params[:passwd]
    
    begin
      hashed_passwd = Digest::SHA256.hexdigest(passwd)
      a = User.find_by(username: name, passwd: hashed_passwd)
      if a == nil
        session[:notfounduser] = "ユーザー名かパスワードが間違っています"
        redirect '/login'
      end
      session[:user_id] = a.user_id

      redirect '/'
    end
  end

  get '/exobjs/new' do
    if session[:user_id] == nil
      redirect '/login'
    end
    @uid = session[:user_id]

    erb :new_exobj
  end

  post '/exobjs/new' do
    if session[:user_id] == nil
      redirect '/login'
    end
    begin
      allowed_filename = [".png", ".jpg", ".jpeg"]
      saved_time = Time.now

      exhibition_obj_base_path = "./public/files/users/#{session[:user_id]}/exobj"
      FileUtils.mkdir_p(exhibition_obj_base_path) unless Dir::exist?(exhibition_obj_base_path)

      e = ExhibitionObjs.new
      file = params[:item_file]

      if file == nil
        e.item_image_fname = ""
      else
        extension = File.extname(file[:filename])
        allowed_filename.each_with_index do |af, i|
          if af == extension
            tmp_path = "#{exhibition_obj_base_path}/#{file[:filename]}"
            File.open(tmp_path, 'wb') do |f|
              g = file[:tempfile]
              f.write g.read
            end
            imgfile = Digest::SHA256.hexdigest(File.open(tmp_path,'rb').read + saved_time.to_s)
            save_path = "#{exhibition_obj_base_path}/#{imgfile}#{extension}"
            File.rename(tmp_path, save_path)
            e.item_image_fname = "#{imgfile}#{extension}"
            break
          end
        end
      end
      e.user_id = session[:user_id]
      e.item_id = SecureRandom.uuid
      e.item_name = CGI.escapeHTML(params[:item_name])
      e.item_info = CGI.escapeHTML(params[:item_info])
      unless params[:remarks] != nil
        e.remarks = CGI.escapeHTML(params[:remarks])
      else 
        e.remarks = ""
      end
      e.joutosaki = params['joutosaki']
      e.deadline = params[:deadline]
      e.created_at = saved_time
      e.save
    rescue => e
      p e
    end

    redirect '/'
  end
  
  # ある出品物の詳細情報
  get '/exobjs/info/:item_id' do
    if session[:user_id] == nil
      redirect '/login'
    end
    @uid = session[:user_id]

    if is_uuid(params[:item_id])
      item = ExhibitionObjs.find_by(item_id: params[:item_id])
      @items = exhibition_obj_component(item)
      @item_id = item.item_id
    end

    erb :exobjs_item
  end

  # ある出品物に対して応募者の登録
  post '/exobjs/info/:item_id/apply' do
    if session[:user_id] == nil
      redirect '/login'
    end
    
    # 出品物と応募者がHasManyの関係
    begin
      a = Applicant.new
      a.applicantion_id = SecureRandom.uuid
      a.user_id = session[:user_id]
      a.purchaser_name = CGI.escapeHTML(params[:purchaser_name])
      a.purchaser_email = CGI.escapeHTML(params[:purchaser_email])
      a.exobj_item_id = params[:item_id]
      if ExhibitionObjs.find_by(item_id: params[:item_id]).joutosaki == "hayaimono"
        a.is_application_closed = "Closed"
      else
        a.is_application_closed = "Open"
      end
      a.save
    rescue => e
      p e
    end
    
    redirect '/'
  end
  
  post '/exobjs/:item_id/delete' do
    if session[:user_id] == nil
      redirect '/login'
    end

    begin
      # 出品物ごと削除
      e = ExhibitionObjs.find_by(item_id: params[:item_id])
      if e[:item_image_fname] != ""
        exhibition_obj_image_path = "./public/files/#{session[:user_id]}/#{e[:item_image_fname]}"
        if File.exist?(exhibition_obj_image_path)
          File.delete(exhibition_obj_image_path)
        end
      end
      e.destroy


      # 出品物に紐付けられた応募者を削除
      a = Applicant.where(exobj_item_id: params[:item_id])
      if a != Applicant.none
        a.each do |ai|
          a.destroy
        end
      end
    rescue => e
      p e
    end
    redirect '/'
  end

  get '/exobjs/search' do
    if session[:user_id] == nil
      redirect '/login'
    end
    @searched_result = session[:searched_result]
    @uid = session[:user_id]

    erb :search
  end

  post '/exobjs/search' do
    if session[:user_id] == nil
      redirect '/login'
    end

    if params[:searching_text] == ""
      redirect '/exobjs/search'
    end

    begin
      s = ExhibitionObjs.where("item_name LIKE ?", "%#{params[:searching_text]}%")
      searched_result = ""
      s.each do |si|
        searched_result += exhibition_obj_component(si)
      end
    rescue => e
      p e
    end
    session[:searched_result] = searched_result
    redirect '/exobjs/search'
  end
  
  # 応募状況確認ページ
  get '/application-status' do
    if session[:user_id] == nil
      redirect '/login'
    end

    @uid = session[:user_id]
    @status = disp_application_status(session[:user_id])
    erb :application_status
  end

  # 自分だけのレコードを表示するか
  # user_idが引数で渡されるとき -> 表示する
  # 引数なし -> (exobjs)全レコード表示する
  def disp_exobjs()
    exobj = ""
    begin
      (ExhibitionObjs.all).each do |a|
        exobj += exhibition_obj_component(a)
      end
    rescue => e
      p e
    end
    return exobj
  end

  # ページネーション
  def disp_exobjs_with_page(page, which)
    exobj = ""
    begin
      e = filter_me_or_other(which, session[:user_id])
      all_pages = (e.count.to_f / LIMIT).ceil
      if page > all_pages
        redirect '/'
      else
        @p = ""
        @p += "<ul class=\"pagination\">"
        (1..all_pages).each do |ai|
          @p += "<li>"
          @p += "<div class=\"pagination-block\">"
          @p += "<a href=\"/?page=#{ai}\">#{ai}</a>"
          @p += "</div>"
          @p += "</li>"
        end
        @p += "</ul>"
      end

      (e.limit(LIMIT).offset(LIMIT * page)).each do |a|
        exobj += exhibition_obj_component(a)
      end
    rescue => e
      p e
    end
    return exobj
  end

  # disp_exobjsのuser_idでフィルタリングした関数
  # ログイン中のユーザーの出品のみ取得
  def disp_exobjs_with_userid(user_id)
    exobj = ""
    begin
      p ExhibitionObjs.where(user_id: user_id)
      (ExhibitionObjs.where(user_id: user_id)).each do |a|
        exobj += exhibition_obj_component(a)
      end
    rescue => e
      p e
    end
    return exobj
  end

  # 自分が出品したものに応募した人を表示
  def disp_application_status(user_id)
    status = ""
    begin
      # 自分以外の応募状況
      (Applicant.where.not(user_id: user_id)).each do |a|
        status += application_status_component(a)
      end
    rescue => e
      p e
    end
    return status
  end

  # r : Exhibition Objs Record(EOR)
  # user : EORのuser_idからuser recordを取得
  def exhibition_obj_component(r)
    if !session[:user_id]
      return ""
    end

    user = User.find_by(user_id: r.user_id)
    # ユーザーと出品情報を表示
    user_exobj_info = user_exobj_info_component(r.item_name, r.deadline, user.username, r.created_at)

    # 応募ボタン
    apply_button = apply_button_component(r.deadline, r.item_id)

    # adminであれば削除可能
    delete_button = admin_can_delete_button_component(r.item_id, r.user_id)

    # 出品物の画像を表示
    exobj_image = exobj_image_component(r.user_id, r.item_image_fname)

    return <<~HTML
    <article class="exobj">
      <div>
        #{user_exobj_info}
        #{apply_button}
        #{delete_button}
      </div>
      #{exobj_image}
    </article>
    HTML
  end

  # r : Applicant Record
  # 応募状況用のコンポーネント
  def application_status_component(r)
    if !session[:user_id]
      return ""
    end

    ExhibitionObjs.where(user_id: session[:user_id]).each do |eo|
      if eo.item_id != r.exobj_item_id
        return ""
      end

      # item_idが一致しているデータがあるとき
      exobj = ExhibitionObjs.find_by(item_id: r.exobj_item_id)
      return <<~HTML
      <article class="exobj">
        <div>
          <span class="user-name">#{r.purchaser_name}</span>
          <span class="user-email">#{r.purchaser_email}</span>
          <span>#{extract_yyyyMMdd(r.created_at)}</span>
          <p>#{exobj.item_name}</p>
          <p>#{exobj.item_info}</p>
        </div>

        #{exobj_image_component(session[:user_id], exobj.item_image_fname)}
      </article>
      HTML
    end
  end

  def apply_button_component(deadline, item_id)
      if !is_application_closed(deadline, item_id)
      # 応募期限内で、応募ボタンを押せる条件を満たしていれば
      apply_button = "<a href=\"/exobjs/info/#{item_id}\"><button class=\"apply-button__button\">応募する</button></a>"
    else
      # 応募期限外
      apply_button = "<button disabled>応募締切</button>"
    end
  end

  def user_exobj_info_component(item_name, deadline, username, created_at)
    return <<~HTML
    <span class="exobj-name">#{item_name}</span>
    <span class="date">#{extract_yyyyMMdd(deadline)}</span>
    <p>#{username}</p>
    <p>#{extract_yyyyMMdd(created_at)}</p>
    HTML
  end

  def admin_can_delete_button_component(item_id, user_id)
    if !(session[:user_id] == user_id) || User.find_by(user_id: session[:user_id]).is_admin
      return ""
    end
    return <<~HTML
    <form action="/exobjs/#{item_id}/delete" method="post" onsubmit="return confirmForm('削除')">
      <input type="hidden" name="user_id" value="#{user_id}">
      <input type="hidden" name="_method" value="delete">
      <div class="exobj-delete--input_container">
        <input class="exobj-delete--input" type="submit" value="削除">
      </div>
    </form>
    HTML
  end

  # 出品物の画像を表示
  def exobj_image_component(user_id, img_fname)
    exhibition_obj_base_path = img_fname == "" ? "/files/no-image-available.png"
                                               : "/files/users/#{user_id}/exobj/#{img_fname}"

    exhibition_obj_alt = img_fname == "" ? "NO IMAGE AVAILABLE"
                                         : "uploaded image"
    return <<~HTML
    <div class="exobj__image">
      <img src="#{exhibition_obj_base_path}" alt="#{exhibition_obj_alt}" >
    </div>
    HTML
  end

  def extract_yyyyMMdd(ymd)
    return ymd.strftime("%Y/%m/%d %H:%M")
  end

  def is_uuid(uid)
    if uid.match(/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/) != nil
      return true
    end
    return false
  end

  # Closed : true
  # Open : false
  def is_application_closed(deadline, item_id)
    begin
      a = Applicant.find_by(exobj_item_id: item_id)
    rescue => e
      p e
    end

    # 応募期限を過ぎていたら
    if is_missed_deadline(deadline, item_id)
      return true
    end

    # 応募者がいるときと、"早いもの勝ち"に応募が来ていたら
    if a != nil && a.is_application_closed == "Closed"
      return true
    end
    return false
  end

  # missed : true
  # not missed : false
  def is_missed_deadline(deadline, item_id)
    if deadline != nil && deadline < DateTime.now.to_time
      if (a = Applicant.find_by(exobj_item_id: item_id)) != nil
        a.is_application_closed = "Closed"
      end
      return true
    end
    return false
  end

  def filter_me_or_other(which, user_id)
      if which == FILETER_OTHER
        return ExhibitionObjs.where.not(user_id: user_id)
      elsif which == FILTER_ME
        return ExhibitionObjs.where(user_id: user_id)
      end
  end
end
