require 'pry'
namespace :rover do
  desc "this task grabs grabs de uri where the rover data is stored, reads it and sends it to the trackin job"
  task tracker: :environment do
    url = test_file_url
    file = File.open(url)
    file_data = file.readlines.map(&:chomp)
    
    plateau_size = file_data[0]
    file_data.delete_at(0)
    counter = 0
    initial_positions = []
    movements = []
    
    file_data.each do |line|
      if(counter % 2 == 0)
        initial_positions << line
        raise "data error" if line.blank?
      else
        movements << line
      end
      counter = counter + 1
    end
    if movements.size != initial_positions.size || initial_positions.size == 0
      raise "data error"
    end
    ending_positions = []
    counter = 0
    initial_positions.each do |init_pos|
      current_pos = init_pos.split
      current_pos = rover_track(current_pos, movements[counter], plateau_size)
      ending_positions << current_pos
      counter = counter + 1
    end
    printer ending_positions
  end
end

def movement_vectors
  {
    'N': [0,1],
    'E': [1,0],
    'W': [-1,0],
    'S': [0,-1]
  }
end

def directional_map
  {
    'NR': 'E',
    'NL': 'W',
    'ER': 'S',
    'EL': 'N',
    'WR': 'N',
    'WL': 'S',
    'SR': 'W',
    'SL': 'E'
  }
end

def acceptable_movements
  ["M", "L", "R"]
end

def test_file_url
  puts "please indicate the exact name of the test file with the extention"
  file_name = gets.chomp
  "test/fixtures/files/#{file_name}"
end

def rover_track(current_pos,movements = [], plateau_size = 0)
  movements.split.each do |action|
    if !(acceptable_movements.include? action)
      raise "data error"
    end
    if action == 'M'
      current_pos[0] = current_pos[0].to_i + movement_vectors[current_pos[2].to_sym][0]
      current_pos[1] = current_pos[1].to_i + movement_vectors[current_pos[2].to_sym][1]
      position_validator(current_pos, plateau_size)
    else
      current_pos[2] = directional_map[(current_pos[2] + action).to_sym]
    end
  end
  current_pos
end

def printer(coord_list)
  coord_list.each do |coordinate|
    p coordinate.join("")
  end
end

def position_validator(coords, plateau_size)
  if coords[0].to_i > plateau_size.to_i || coords[1].to_i > plateau_size.to_i || coords[0].to_i < 0 || coords[1].to_i < 0
    raise "rover fell from plateau"
  end
end
