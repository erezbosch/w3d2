require_relative 'model'

class QuestionFollow < Model

  def self.followers_for_question_id(question_id)
    followers_data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN
        users ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL

    followers_data.map { |follower_data| User.new(follower_data) }
  end

  def self.most_followed_questions(n)
    most_followed_qs = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(question_follows.id) DESC
      LIMIT
        ?
    SQL

    most_followed_qs.map { |question_data| Question.new(question_data) }
  end

  def self.followed_questions_for_user_id(user_id)
    followed_qs_data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL

    followed_qs_data.map { |question_data| Question.new(question_data) }
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
