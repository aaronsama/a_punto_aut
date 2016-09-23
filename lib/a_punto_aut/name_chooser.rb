require 'thor'
require 'yaml'
require 'active_support/core_ext/hash/slice'

# Allows you to choose names
module APuntoAut
  class NameChooser < Thor
    desc 'choosefrom FILE', "choose a name from FILE (until it's empty)"
    def choosefrom(file)
      init_names(file)
      init_scores(file)

      say "There are still #{@names.count} names to choose from"

      begin
        loop { ask_name @names.sample }
      rescue SystemExit, Interrupt
        save_file(file)
        save_scores(file)
        # raise
        exit
      end
    end

    desc 'play NAMES_FILE CRITERIA_FILE', 'find a winner by playing all the names against the others'
    def play(names, criteria_file)
      init_names(names)
      criteria = YAML.load_file(criteria_file)
      @strength = {}

      say 'Answer a few questions about the names you have shortlisted'

      @names.each do |name|
        say name.upcase, :magenta
        @strength[name] = []
        criteria.each do |_, c|
          score = ask c['question'], limited_to: %w(1 2 3 4 5)
          @strength[name] << score.to_f * (c['weight1'] * c['weight2'])
        end

        @strength[name] = @strength[name].reduce :+
      end

      say 'Wait a moment...'

      @final_scores = @names.zip(Array.new(@names.count, 0)).to_h
      @names.combination(2).each do |(name1, name2)|
        vs(name1, name2)
      end

      say 'Here are the final scores!', :green
      @final_scores.sort_by { |_, final_score| final_score }
                   .reverse
                   .each do |(name, final_score)|
        puts "#{name}: #{final_score}"
      end
    end

    private

    def vs(name1, name2)
      if @strength[name1] > @strength[name2]
        win name1
      elsif @strength[name1] < @strength[name2]
        win name2
      else
        tie(name1, name2)
      end
    end

    def win(name)
      @final_scores[name] += 3
    end

    def tie(name1, name2)
      @final_scores[name1] += 1
      @final_scores[name2] += 1
    end

    def ask_name(name)
      display_name = name.strip.capitalize # this is a displayable name
      res = yes?("Do you like #{display_name} (#{@names.size} left)?", :magenta)

      if res
        @scores[display_name] += 1
      elsif @scores[display_name] > 1
        @scores[display_name] -= 1
      else
        @names.delete(name)
        @scores.delete(display_name)
      end
    end

    def save_file(file)
      File.open(file, 'w') do |f|
        f.write(@names.join(''))
      end
    end

    def init_names(file)
      @names = File.readlines(file).map { |n| n.delete ' ' }.uniq
      @names.map!(&:strip)
    end

    def init_scores(file)
      @scores = Hash.new 0
      begin
        @scores.merge! YAML.load_file(file.gsub(/(\..+)$/, '_scores.yml'))
      rescue
        say 'Initializing scores...'
      end
    end

    def save_scores(file)
      File.open(file.gsub(/(\.[[:alpha:]]+)$/, '_scores.yml'), 'w') do |f|
        f.write @scores.to_yaml
      end
    end
  end
end
