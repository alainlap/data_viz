require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

def fetch_tm
		counter = 1

		agent = Mechanize.new

		# Open advanced search page
		page = agent.get('...')

		# Select form
		search_form = page.form("searchActionForm")

		# Submit form
		set_cookie_page = agent.submit(search_form, search_form.buttons.first)

		# Get prefix with cookies from results page
		cookies = set_cookie_page.uri.to_s
		cut_at = cookies.index("?")
		cookies.slice!(cut_at..-1)

		# Add my parameters to url
		selectDocsPerPage = 10000
		docsStart = counter*selectDocsPerPage
		parameters = "..."
		url = cookies + parameters

		# Open search page with new parameters
		search_results = agent.get(url)

		output = search_results.search('.v_docTitle a').text

		# Output raw html to file
		File.open("raw_output#{counter}.txt", "w") {|file| file.puts output}

		puts "Finished printing file no. #{counter}"
end

def parse_results
		puts "parsing file no. #{i}"
		parse_file(i)
end

def parse_file(i)

	file = File.open("./raw_output/raw_output#{i}.txt", "r") {|f| f.read}
	
	# clean up strings
	file.gsub!("...", "")
	3.times {file.gsub!("  ", " ")}
	entries = file.split("\n")

	entries.reject! { |item| item == "" || item == " " || item == "  "}
	entries.map! {|item|
		item.strip
		split1 = item.split(", ")
		split1[0]
	}

	entries.map! {|item|
		item.gsub("-", " ").split(" ")
	}
	entries = entries.flatten

	File.open("./clean_output/clean_output0.txt", "a") {|f| f.puts entries}
end

def sort_results
	f = File.open("clean_output/clean_output0.txt", "r")
	clean = f.read
	f.close

	array = clean.split("\n")

	freq = Hash.new(0)
	array.each do |word|
		freq[word] += 1
	end

	freq = freq.sort_by {|k, v| v}.reverse

	f = File.open("clean_output/frequencies.txt", "a")

	freq.each do |key, value|
		f.puts "#{key} : #{value}"
	end
end

fetch_tm
parse_results
sort_results


