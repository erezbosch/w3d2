require_relative 'model'

class Reply < Model

  def self.find_by_user_id(user_id)
    reply_data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    Reply.new(reply_data.first)
  end

  def self.find_by_question_id(question_id)
    reply_data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    Reply.new(reply_data.first)
  end

  attr_accessor :id, :body, :question_id, :parent_id, :user_id

  def initialize(options = {})
    @id = options['id']
    @body = options['body']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    self.class.find_by_id(parent_id)
  end

  def child_replies
    child_replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    child_replies.map { |child| Reply.new(child) }
  end
end
