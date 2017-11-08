require 'optparse'

module WordReplacer
  class Processor
    OPTIONS = [:word, :replacement, :path]
    include Singleton

    def options
      @options||= {}
    end

    def process
      parse_input
      case
        when File.directory?(options[:path])
          replace_in_path options[:word], options[:replacement], options[:path]
        else
          replace_text options[:word], options[:replacement], options[:path]
      end
      puts "Replacement Done"
    end

    def parse_input
      opts = {}
      OptionParser.new do |opt|
        opt.on('-w','--word [WORD]', 'the word to replace') { |o| opts[:word] = o }
        opt.on('-r','--replacement [REPLACEMENT]', 'the replacement') { |o| opts[:replacement] = o }
        opt.on('-p','--path [PATH]', 'the path or file where is going to be replaced') { |o| opts[:path] = o }
      end.parse!
      OPTIONS.each do |opt_name|
        options[opt_name] = opts.fetch(opt_name) do
          raise ArgumentError, "no '#{opt_name.to_s}' option specified as a parameter"
        end
      end
      puts "Processing input: #{options.inspect}"
    end

    def replace_text(word, replacement, path)
      data = File.read(path)
      if data.include? word
        filtered_data = data.gsub(word, replacement)
        # open the file for writing
        File.open(path, "w") do |f|
          f.write(filtered_data)
        end
      end
    end

    def replace_in_path(word, replacement, path)
      Dir["#{path}/**/*"].select{|f| File.file?(f) }.each do |file_path|
        replace_text(word, replacement, file_path)
      end
    end
  end
end
