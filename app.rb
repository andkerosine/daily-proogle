require 'json'
require 'haml'
require 'sequel'
require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

DB = Sequel.connect ENV['DATABASE_URL'] || 'sqlite://./daily_proogle.db'

solutions = DB[:solutions].all
titles = DB[:challenges].to_hash :id, :title
langs = DB[:solutions].distinct.select(:language).map(&:values).flatten.sort

get '/' do
  haml :index, locals: {langs: langs}
end

get '/search' do
  if session[:prev] and Time.now.to_i - session[:prev] < 5
    return '{"error": "Slow down."}'
  end
  session[:prev] = Time.now.to_i

  author = params[:author]   || ''
  lang   = params[:language] || ''
  length = params[:length]   || ''

  return '{"error": "Invalid length."}' if length[/\D/]

  filters = []
  filters <<-> sol { sol[:author][author] } unless author.empty?
  filters <<-> sol { sol[:language] == lang } unless lang.empty?
  filters <<-> sol { (1..length.to_i) === sol[:length] } unless length.empty?

  return '{"error": "Need some kind of filter."}' if filters.empty?

  results = filters.reduce(solutions) { |sols, filter| sols.select &filter }
  results.map { |res| res.merge title: titles[res[:ref]] }.to_json
end
