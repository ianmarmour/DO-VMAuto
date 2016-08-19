require 'droplet_kit'

v1 = ARGV[0]
v2 = ARGV[1]
v3 = ARGV[2]
v4 = ARGV[3]

file = File.open("token.txt", "rb")
access_token = file.read

if v1 != nil && v2 != nil && v3 != nil && v4 != nil
	puts "You entered vars from CMD LINE" 
	name = v1
	region = v2
	os = v3
	size = v4
else
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

	puts "\nDigitalocean Droplet Maker\n"

	puts "\nPlease enter a name for your Droplet:"
	name = gets.chomp

	puts "\nPlease select a region for your Droplet:"
	regions.each { |n,r| puts n + ") " + r }
	region = gets.chomp
	region = regions[region]

	puts "\nPlease select a OS for your Droplet:"
	operatingsystems.each { |n,r| puts n + ") " + r}
	os = gets.chomp
	os = operatingsystems[os]

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

client = DropletKit::Client.new(access_token: access_token)

my_ssh_keys = client.ssh_keys.all.collect {|key| key.fingerprint}

droplet = DropletKit::Droplet.new(name: name, region: region, image: os, size: size, ssh_keys: my_ssh_keys)

created = client.droplets.create(droplet)

mytargetdroplet = client.droplets.find(id: created.id) 

while mytargetdroplet.status != "active" do
  sleep(5)
  puts "Waiting for Droplet Creation."
  puts mytargetdroplet.status
  mytargetdroplet = client.droplets.find(id: created.id)
end

$stdout.write mytargetdroplet.networks.v4[0].ip_address.to_s
