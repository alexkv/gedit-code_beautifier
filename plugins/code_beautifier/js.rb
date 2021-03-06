#!/usr/bin/ruby

def print_usage
	puts "
	Usage: #{File.basename($0)} file
	Usage: echo 'JavaScript input' | #{File.basename($0)}

	Using this is a vim filter command
	----------------------------------

	This can also be used as a vim filter command (see help filter).

	Simply select the lines to be beautified in visual mode and type .!beautify_js.

	Better yet, create a vim command to execute it for you, and put that in your .vimrc:
	command! -range=% -nargs=0 BeautifyJavascript <line1>,<line2>!JSBEAUTY=<q-args> #{$0}

This will allow you to invoke the command when editing a file as
	:BeautifyJavascript

	Additionally you can provide some of the following command line arguments:
	-i <#>   -- The number of spaces to indent the code;use 1 to use tabs (Def:2)
	-n       -- Preserve line feeds
	-p       -- A mode to place a space between function and () for jslint.

	Examples would be:

	:BeautifyJavascript -i 4 -n
	:BeautifyJavascript -n

	Then you can simply type BeautifyJavascript to process the entire buffer or select a range of lines to only pass those lines through the filter.
	"
	exit
end


if STDIN.tty?
	if ARGV.size >= 1
		# Get the absolute path of the filename given
		require 'pathname'
		last = ARGV.size - 1
		args = ""
		path = ""
		ARGV.size.times {|i|
			if i == last
				path = Pathname.new(ARGV[i]).realpath.to_s
			else
				if i > 0
					args += " "
				end
				args += "#{ARGV[i]}"
			end
		}
		#path = Pathname.new(ARGV[0]).realpath.to_s
	else
		print_usage
	end
else
	# Assume they are piping the input in. Save that input in a temporary file and pass that file to beautify-cl.js
	require 'tempfile'
	file = Tempfile.new('beautify_js')
	file.puts STDIN.read
	file.close
	args = ENV['JSBEAUTY'] || ""
	path = file.path
end
#system "cat #{path}"


# Change directory so that the load() calls in beautify-cl.js are able to find the files they need
Dir.chdir File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__)
Dir.chdir '..'
#puts Dir.getwd


command = "rhino beautify-cl.js '#{args} #{path}' 2>&1"
#puts command
#output = `#{command}`
system command

