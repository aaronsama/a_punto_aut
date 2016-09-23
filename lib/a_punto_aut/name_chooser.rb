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

    desc 'play SCORES_FILE GROUP_SIZE', 'find a winner by playing all the names against the others'
    def play(scores_file, group_size)
      @scores = YAML.load_file(scores_file)
      @scores.each { |n, _| @scores[n] = 0 }
      names = @scores.keys

      say 'GROUPS STAGE', :green
      group_stage(names, group_size.to_i)
      print_table @scores.to_a
      save_scores('group_stage.yml')

      say 'KNOCKOUT STAGE', :green
      say 'Pending'
    end

    private

    def group_stage(names, group_size)
      say 'Seeding groups...', :yellow
      names.shuffle.each_slice(group_size).with_index do |group, group_id|
        say "Group #{group_id + 1}\n======", :magenta
        group.combination(2).each { |(name1, name2)| vs(name1, name2) }

        @scores["Group #{group_id + 1}"] = @scores.slice(*group)
        group.each { |n| @scores.delete n }
      end
    end

    def vs(name1, name2)
      res = ask "#{name1} vs #{name2}", limited_to: [name1, name2]
      # tie(name1, name2) if res == '='
      win(res) unless res == '='
    end

    def win(name)
      @scores[name] += 3
    end

    # def tie(name1, name2)
    #   @scores[name1] += 1
    #   @scores[name2] += 1
    # end

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
      File.open(file.gsub(/(\.[[:alpha:]]+)$/, '_scores.yml'), 'w') { |f| f.write @scores.to_yaml }
    end
  end
end
