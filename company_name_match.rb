require 'i18n'

I18n.enforce_available_locales = false

# scoring:
#
# subtract 10 points for missing common words (a, the)
# subtract 20 points for other missing words
# but only 5 if it's a sub word like inc
# subtract 30 points for every incorrect word order
# subtract 3 points for every accented letter that doesn't match

module CompanyNameMatcher

  class Score
    attr_accessor :score

    def initialize(n)
      @score = n
    end

    def deduct(n)
      @score -= n.to_i
    end

    def to_i
      @score
    end
  end

  class Match

    NAME_SUBSTITUTIONS  = {
        :and            => %w( and & +               ),
        :private        => %w( private pvt (pvt) (p) ),
        :limited        => %w( limited ltd           ),
        :company        => %w( company co            ),
        :international  => %w( intl international    ),
        :corporation    => %w( corp corporation      ),
        :incorperated   => %w( inc incorporated      ),
    }

    COMMON_WORDS         = %w( a the )

    DEDUCT_SUB_WORDS        = 5
    DEDUCT_COMMON_WORDS     = 10
    DEDUCT_MISSING_WORDS    = 25
    DEDUCT_WRONG_ORDER      = 30
    DEDUCT_MISSING_ACCENTS  = 3

    def initialize(first_name, second_name)
      @first_name_raw   = first_name
      @second_name_raw  = second_name
      @score            = Score.new(100)

      get_formatted_names
      calculate_score
    end

    def score
      @score.score
    end

protected

    def get_formatted_names

      f = I18n.transliterate(@first_name_raw)
      s = I18n.transliterate(@second_name_raw)

      f_accents = (@first_name_raw.split('')  - f.split('')).count
      s_accents = (@second_name_raw.split('') - s.split('')).count

      accents_diff = [f_accents, s_accents].max - [f_accents, s_accents].min

      @score.deduct(accents_diff * DEDUCT_MISSING_ACCENTS)

      @first_name  = format(f)
      @second_name = format(s)

    end

    # strip punctuation and transliterate
    def format(name)
      name.gsub(/[\.,]/, '').downcase
    end

    def self.score(first_name, second_name)
      self.new(first_name, second_name).score
    end

    def calculate_score

      # split the name by spaces
      @first_name_words  = @first_name.split(' ')
      @second_name_words = @second_name.split(' ')
      @subwords_found    = {}

      unmatched_words   = (@first_name_words - @second_name_words) + (@second_name_words - @first_name_words)
      remove_unmatched  = []

      unmatched_words.reverse_each do |word|

        if sub_word_type = is_sub_word?(word)

          unless @subwords_found[sub_word_type]
            @score.deduct DEDUCT_SUB_WORDS
            @subwords_found[sub_word_type] = true
          end

          next

        elsif COMMON_WORDS.member?(word)

          @score.deduct DEDUCT_COMMON_WORDS
          next

        else
          remove_unmatched.push(word)
        end

      end

      # deduct points for every unmatched word
      @score.deduct(remove_unmatched.count * DEDUCT_MISSING_WORDS)

      # now compare the order of the matched words
      matched_first   = @first_name_words  - unmatched_words
      matched_second  = @second_name_words - unmatched_words

      matched_first.each_with_index { |word, i| @score.deduct DEDUCT_WRONG_ORDER unless word == matched_second[i] }

      @score

    end

    def is_sub_word?(word)

      NAME_SUBSTITUTIONS.each do |type, words|
        return type if words.member?(word)
      end

      false

    end

    def score_length

      max = [@first_name_words.length, @second_name_words].max
      min = [@first_name_words.length, @second_name_words].min

      return (max - min) * 10
    end

  end
end
