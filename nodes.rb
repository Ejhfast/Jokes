require 'statistics2'

node_num = ARGV[0].to_i
joke_num = ARGV[1].to_i
csv_file = File.new(ARGV[2],"w")
joke_scew = ARGV[3].to_i

# Initialize node "personalities"
nodes = (1..node_num).map{|x| (rand*4)-2}

# Initialize joke types
# Do we want to scew joke types to personalities, or keep
# them arbitrarily random?
if joke_scew == 1
	jokes = nodes.map{|x| ((-1) ** (rand 2))*( (rand) / 4)}
else
	jokes = (1..joke_num).to_a.map{|x| (rand*4) - 2 }
end

# Hashes for signal tracking
weight_hash = Hash.new
signal_hash = Hash.new

# Set all initial signals to 0
(0..(joke_num-1)).each do |jk|
	(0..(node_num-1)).each do |n|
		signal_hash[[jk,n]]=0.0
	end
end

# If we want to print out an adjaceny matrix, we can do it
# in here
s = ""
(0..(node_num-1)).each do |nx|
	(0..(node_num-1)).each do |ny|
		w = (rand) * ((1 - (nodes[nx] - nodes[ny]).abs/4.to_f))  
		weight_hash[[nx,ny]] = w
		s = s + "#{w},"
	end
end

# Evaluate a personality's distribution on a joke type
def normdist(joke,personality)
	Statistics2.normaldist(-1 * (joke - personality).abs)
end

# Probability of node activation
def act_fun(pnum, jnum, signal, signal_hash, nodes, jokes)
	alpha_decay = 1.5
	begin
		sh = signal_hash[[jnum,pnum]]
		div_factor = signal.to_f ** alpha_decay
		nd = normdist(jokes[jnum],nodes[pnum])
		out = sh * ((nd * 2) / div_factor) / sh
		out
	rescue
		0
	end
end

# Place Jokes Randomly
(0..(joke_num-1)).each do |j|
	(0..(node_num-1)).each do |n|
		if (rand) < (joke_num / (10 * joke_num ** 2))
			signal_hash[[j,n]] = 1
		else
			signal_hash[[j,n]] = 0
		end
	end
end

# Keep going?
go=true

# Track timestep for .csv
t=0

while (go==true)
	go=false
	t=t+1
	outinfo = ""
	activated = false

# Loop through all nodes
nodes.each_index do |node|
	# Reset activation, total signal
	activated = false
	sig = 0
	# Sum the total signal for the current node
	jokes.each_index do |jk|
		sig = sig + signal_hash[[jk,node]]
	end
	# Loop though all jokes for the current node
	jokes.each_index do |jk|
		# Does it activate?
		activation = act_fun(node,jk,sig,signal_hash,nodes,jokes)
		if (rand) < activation #activated
			activated = true
			# If activated, to whom does it send a signal (if anyone?)
			nodes.each_index do |second_node|
				if (rand) < weight_hash[[node,second_node]]
					signal_hash[[jk,second_node]] = signal_hash[[jk,second_node]] + 1
					sig = sig + 1
					go=true
					puts "\t\tsending signals to node #{second_node}"
				else
				end
			end
		end
	end
	# Record whether a node was activated
	if activated
		outinfo = outinfo + "1,"
	else
		outinfo = outinfo + "0, "
	end
end
csv_file.puts "#{outinfo}"
end

csv_file.close
