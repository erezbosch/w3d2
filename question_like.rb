class QuestionLike < Model

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL,question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN
        users ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    likers.map {|liker| User.new(liker)}
  end

  def self.num_likes_for_question_id(question_id)
    num_of_likes = QuestionsDatabase.instance.execute(<<-SQL,question_id)
      SELECT
        COALESCE(COUNT(user_id), 0) as count
      FROM
        question_likes
      WHERE
        question_likes.question_id = ?
      GROUP BY
        question_id
    SQL

    num_of_likes.first['count']
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    liked_questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    most_liked_qs = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON question_likes.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        count(question_likes.user_id) DESC
      LIMIT
        ?
    SQL

    most_liked_qs.map { |question| Question.new(question) }
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options = {})
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
