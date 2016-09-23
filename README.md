# APuntoAut (obviously just a placeholder name)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/a_punto_aut`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'a_punto_aut'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install a_punto_aut

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aaronsama/a_punto_aut.

## Usage

Refer to the [[Algorithm]] section below.

## Algorithm

### Phase 1

In this phase we take all the names from a file and we ask the user if they like each name. Execute

    $ a_punto_aut choosefrom <FILENAME>

    FILENAME: a txt file with one name per line

1. The script randomizes the list and presents a prompt for each name asking if you like the name shown. Each name starts with a score of 1. If you have executed the script before, the names will be initialized with the scores previously accrued.
2. If you answer `y` or `yes` the name will be kept and its score will increase by 1. If you answer anything else, the name's score will decrease by 1. If a name's score reaches 0, it is removed from the list.
3. If you terminate the script (by pressing CTRL+C) the list is saved and the scores are saved in a separate yml file in the same directory of the list.
4. When the list is of the desired size you can stop and pass the scores file to the next phase.

### Phase 2

At this point you should have a list of names with a score (i.e. the number of times they were accepted).

In this phase we decide the winner by pitching every name against all the other names. To do that we need:

* the list of names that made it this far (which is the output of phase 1)
* a set of parameters you want to evaluate each name against
* the weight of each parameter according to each parent of the child

execute

    $ a_punto_aut play <NAMES> --parameters=<PARAMS_CONFIG>
    NAMES: the names that made it to the finals
    PARMS_CONFIG: a yml file with the configuration of the parameters

The configuration file with the parameters should be structured as follows:

```yml
<param_short_name>:
  question: Is this name ...?
  weight1: a decimal number between 0.5 and 2.0
  weight2: a decimal number between 0.5 and 2.0

# example
meaning:
  question: How much do you like the meaning of this name?
  weight1: 1.2
  weight2: 0.9
```

The process is the following:

1. the script prompts each name of the list followed by each question. To answer, enter a score between 1 and 5.
2. The score of each name is the sum of the scores for each parameter, each multiplied by the product of the two weights of that parameter (example: using the parameter example above, if the score for `meaning` is 3, then the weighted score is `3 * (1.2 * 0.9) = 3.24`).
3. The script pitches every name against the others, assigning 3 points to the winner, 0 points to the loser and 1 point in case of draw (like in the Italian soccer championship).
4. Finally, the script outputs the final ranking of each names and hopefully you should see the future name of your child.
