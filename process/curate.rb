require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

db = SQLite3::Database.new 'daily_proogle.db'
rows = db.execute('SELECT * FROM solutions')

get '/:i' do
  @id, @code, @author, @lang, @length, @level, @ref = rows[params[:i].to_i]
  haml :index
end

post '/curate' do
  lang, id, op = params[:lang], params[:id], params[:op]
  db.execute case op
    when 'delete' then "DELETE FROM solutions WHERE id = '#{id}'"
    else "UPDATE solutions SET language='#{lang}' WHERE id='#{id}'"
  end

  cont = params[:i].to_i + (op == 'delete' ? 0 : 1);
  redirect "/#{cont}"
end
