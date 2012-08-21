require 'cgi'
require 'snooby'
require 'sqlite3'

db = SQLite3::Database.new 'daily_proogle.db'
db.execute_batch <<-SQL
  CREATE TABLE IF NOT EXISTS challenges (
    id    TEXT,
    title TEXT
  );

  CREATE TABLE IF NOT EXISTS solutions (
    id       TEXT,
    code     TEXT,
    author   TEXT,
    language TEXT,
    length    INT, -- Fore!
    level     INT,
    ref      TEXT  -- This acts as a simple index into the challenges table
  )                -- to avoid storing unnecessary copies of the same title.
SQL

def insertion table, count
  "INSERT INTO #{table} VALUES (#{['?'] * count * ','})"
end

new_challenge = db.prepare insertion 'challenges', 2
new_solution  = db.prepare insertion 'solutions',  7

known = Hash[db.execute 'SELECT * FROM challenges']

reddit = Snooby::Client.new 'Daily Proogle'
reddit.r('dailyprogrammer').posts(1000).each do |post|
  puts post.title
  next if known[post.id]

  # Skip the occasional non-challenge.
  next unless post.title[/].+#/]

  db.transaction
  new_challenge.execute post.id, post.title.strip # Random newlines?

  post.comments(1000).each do |comment|
    puts comment.id

    # Prevent choking on deleted comments and try to ignore non-code.
    next unless comment.author && comment.body[/    |https?:/]

    code = CGI.unescapeHTML comment.body
    level = post.title.upcase[/\[([DIEH])/, 1]

    info = [comment.id, code, comment.author, comment.author_flair_text]
    info << code.lines.grep(/^(    |\t)/).map(&:strip).join.size
    info << 2 - 'DIEH'.index(level) % 3
    info << post.id

    new_solution.execute *info
  end

  db.commit
end
