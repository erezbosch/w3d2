require 'singleton'
require 'sqlite3'
require_relative 'model'
require_relative 'user'
require_relative 'question'
require_relative 'question_follow'
require_relative 'reply'
require_relative 'question_like'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.results_as_hash = true
    self.type_translation = true
  end
end


if __FILE__ == $PROGRAM_NAME
  u = User.new('fname' => "abc", 'lname' => "def")
  u.save
  u.fname = "Jake"
  u.save
end
