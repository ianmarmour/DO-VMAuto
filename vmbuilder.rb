# GEM requires
require 'droplet_kit'
require 'colorize'
require 'optparse'
require 'ostruct'

# Options parsing
options = OpenStruct.new
OptionParser.new do |opt|
	opt.on('-o', '--output OUTPUT', 'The output directory') { |o| options.output = o }
	opt.on('-s', '--size SIZE', 'The VMs RAM Spec') { |o| options.size = o }
	opt.on('-n', '--name NAME,NAME1,NAME2', Array, "List of name/names of VMs") { |o| options.name = o }
	opt.on('-r', '--region REGION', 'THE VMs Region') { |o| options.region = o }
	opt.on('-i', '--image IMAGE', 'The VMs Operating System') { |o| options.image = o }
	opt.on('-t', '--token TOKEN', 'The token file location') { |o| options.token = o }
end.parse!

# Cleans up vars so we can use the same var names later
options.name != nil ? name = options.name : name = "default"
options.region != nil ? region = options.region : region = "nyc1"
options.image != nil ? image = options.image : image = "ubuntu-16-04-x64"
options.size != nil ? size = options.size : size = "512mb"
options.token != nil ? token = options.token : token = nil
options.output != nil ? output = options.output : output = ""

# Token file reader
file = File.open(token, "rb")
token = file.read

# If params aren't set this defaults to terminal UI mode
if(name == nil || region == nil || image == nil || size == nil || token == nil || output == nil)
	# This is the terminal based gui
	operatingsystems = {
		"1" => "ubuntu-16-04-x64",
		"2" => "centos-7-0-x64",
		"3" => "debian-8-x64",
	}

	regions = {
		"1" => "nyc1",
		"2" => "nyc2",
		"3" => "nyc3",
		"4" => "lon1",
	}

	sizes = {
		"1" => "512mb",
		"2" => "1gb",
		"3" => "2gb",
		"4" => "4gb",
	}

	puts "\nDigitalocean Droplet Maker\n".red

	puts "\nPlease enter a name for your Droplet:"
	name = gets.chomp

	puts "\nPlease select a region for your Droplet:"
	regions.each { |n,r| puts n + ") " + r }
	region = gets.chomp
	region = regions[region]

	puts "\nPlease select a OS for your Droplet:"
	images.each { |n,r| puts n + ") " + r}
	image = gets.chomp
	image = images[image]

	puts "\nPlease select the amount of ram for your Droplet:"
	sizes.each { |n,r| puts n + ") " + r}
	size = gets.chomp
	size = sizes[size]

	puts "\nYour VM specifications"
	puts "Name: #{name}"
	puts "Region: #{region}"
	puts "OS: #{os}"
	puts "Size: #{size}"
	print "\n Is this correct? (y/n): "
	selection = gets.chomp
end

#Generates a new dropletkit client based on access token
client = DropletKit::Client.new(access_token: token)

#Creates an array of all the SSH keys on your DO account
my_ssh_keys = client.ssh_keys.all.collect {|key| key.fingerprint}

(0..name.length).each do |i|

  if i >= name.length then
    break
  end

  thr = Thread.new {
    droplet = DropletKit::Droplet.new(name: name[i], region: region, image: image, size: size, ssh_keys: my_ssh_keys)
    
    created = client.droplets.create(droplet)

    mytargetdroplet = client.droplets.find(id: created.id)

   #Wait for Droplet to come on line before returning IP, this is done for ease of automation.
   while mytargetdroplet.status != "active" do
     sleep(5)
     puts "Waiting for Droplet Creation."
     mytargetdroplet = client.droplets.find(id: created.id)
   end

   #Outputs IP to a file vs STDOUT
   if output != nil
     output = File.open( output,"a")
     output << mytargetdroplet.networks.v4[0].ip_address.to_s + "\n"
     output.close
     outputname = File.basename options.output
     puts "Output written to: " + outputname
   else
     $stdout.write mytargetdroplet.networks.v4[0].ip_address.to_s
   end
  }
  
  thr.join
  thr.exit
end
