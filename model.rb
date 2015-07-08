require 'byebug'

class Model

  @@conditions = {}

  def self.find_col
   col_names = QuestionsDatabase.instance.execute(<<-SQL)
    PRAGMA
      table_info("#{self.get_table}")
    SQL
    col_names = col_names.map { |hash| hash['name'] }
  end

  def self.find_by(search_str)
    data = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.get_table}
    WHERE
      #{search_str}
    SQL

    data.empty? ? nil : data.map { |datum| self.new(datum) }
  end

  def self.method_missing(method_name, *args)
    if method_name[0..7] == "find_by_"
      cols = method_name[8..-1].split("_and_")
      raise "You can't search by that" unless self.check_ivar(cols)
      self.find_by(self.make_search_str(cols,args))
    end
  end

  def self.check_ivar(cols)
    cols.all? { |col| find_col.include?(col) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.get_table}
      WHERE
        id = ?
    SQL

    data.empty? ? nil : self.new(data.first)
  end

  def self.make_search_str(cols, values)
    search_arr = []
    cols.length.times do |idx|
      if values[idx].is_a?(Fixnum)
        search_arr << "#{cols[idx]} = #{values[idx]}"
      else
        search_arr << "#{cols[idx]} = '#{values[idx]}'"
      end
    end
    search_str = search_arr.join(" AND ")
  end

  # def self.where(options = {})
  #   cols = options.keys.map(&:to_s)
  #   raise "You can't search by that" unless self.check_ivar(cols)
  #   values = options.values
  #   self.find_by(self.make_search_str(cols, values))
  # end

  # Reply.where(:parent_id => 1).where(:question_id => 1).where

  def self.where(options = {})
    @@conditions.merge!(options)
    if options.empty?
      self.where!
    else
      self
    end
  end

  def self.where!
    cols = @@conditions.keys.map(&:to_s)
    raise "You can't search by that" unless self.check_ivar(cols)
    values = @@conditions.values
    @@conditions = {}
    self.find_by(self.make_search_str(cols, values))
  end



  def self.all
    all_data = QuestionsDatabase.instance.execute("SELECT * FROM #{self.get_table}")
    all_data.map { |data| self.new(data) }
  end

  def self.get_table
    return "replies" if self == Reply
    class_name = self.to_s.downcase
    name_array = class_name.split /(?=[A-Z])/
    name_array.join("_") + "s"
  end

  def where(options = {})

  end

  def save
    ivar_names = get_ivars_as_strings.drop(1)
    ivar_values = ivar_names.map { |ivar| send(ivar) }

    if id.nil?
      ivar_string = ivar_names.join(", ")
      question_mark_string = (["?"] * ivar_names.length).join(", ")

      QuestionsDatabase.instance.execute(<<-SQL, *ivar_values)
        INSERT INTO
          #{self.class.get_table}(#{ivar_string})
        VALUES
          (#{question_mark_string})
      SQL

      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      vars = []
      ivar_values.length.times do |idx|
        vars << "#{ivar_names[idx]} = '#{ivar_values[idx]}'"
      end
      var_equalities = vars.join(", ")

      QuestionsDatabase.instance.execute(<<-SQL, id)
        UPDATE
          #{self.class.get_table}
        SET
          #{var_equalities}
        WHERE
          id = ?
        SQL
    end
  end

  def get_ivars_as_strings
    self.instance_variables.map { |ivar| ivar.to_s[1..-1] }
  end
end
