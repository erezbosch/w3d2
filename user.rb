require_relative 'model'

class User < Model

  def self.find_by_name(fname, lname)
    user_data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? and lname = ?
    SQL

    User.new(user_data.first)
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        CAST(qs_and_likes.num_likes AS FLOAT) / qs_and_likes.num_qs
      FROM
        (
        SELECT
          author_id, COUNT(DISTINCT(questions.id)) AS num_qs, COUNT(question_likes.id) AS num_likes
        FROM
          questions
        LEFT OUTER JOIN
          question_likes ON question_likes.question_id = questions.id
        GROUP BY
          questions.id
        ) AS qs_and_likes
      WHERE
        qs_and_likes.author_id = ?
      SQL
  end
end
