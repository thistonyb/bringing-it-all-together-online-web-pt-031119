
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    self
  end

  def self.create(hash)
    new_dog = Dog.new(hash) #Ask question about keyword.
    hash.each do |key, attribute|
      new_dog.send("#{key}=", attribute)
    end
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    dog_array = DB[:conn].execute(sql, id)
    Dog.new(id: id, name: dog_array[1], breed: dog_array[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    dog_array = DB[:conn].execute(sql, name, breed)
    if !dog_array.empty?
      dog_info = dog_array[0]
      dog = new_from_db(dog_info)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(array)
    Dog.new(id: array[0], name: array[1], breed: [2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
      

end
