require_relative 'model'

class Question < Model

  def self.find_by_author_id(author_id)
    question_data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    Question.new(question_data.first)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  attr_accessor :id, :title, :body, :author_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(author_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_of_likes(id)
  end
end
