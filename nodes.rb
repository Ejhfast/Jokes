require 'statistics2'

node_num = ARGV[0].to_i
joke_num = ARGV[1].to_i
csv_file = File.new(ARGV[2],"w")
joke_scew = ARGV[3].to_i
#edge_w = File.new(ARGV[3],"w")

weight_hash = Hash.new
nodes = (1..node_num).map{|x| (rand*4)-2}
signal_hash = Hash.new

(0..(joke_num-1)).each do |jk|
	(0..(node_num-1)).each do |n|
		signal_hash[[jk,n]]=0.0
	end
end

jokes = (1..joke_num).to_a.map{|x| (rand*4) - 2 }

if joke_scew == 1
	jokes = nodes.map{|x| ((-1) ** (rand 2))*( (rand) / 4)}
end

(0..(node_num-1)).each do |nx|
	s = ""
	(0..(node_num-1)).each do |ny|
		w = (rand) * ((1 - (nodes[nx] - nodes[ny]).abs/4.to_f))  
		weight_hash[[nx,ny]] = w
		s = s + "#{w},"
	end
#	edge_w.puts "#{s}"
end

def normdist(joke,personality)
	out = Statistics2.normaldist(-1 * (joke - personality).abs)
	#puts "#norm computation #{out}"
	out
end

def act_fun(pnum, jnum, signal, signal_hash, nodes, jokes)
	begin
		sh = signal_hash[[jnum,pnum]]
		div_factor = signal.to_f ** 1.0
		nd = normdist(jokes[jnum],nodes[pnum])
#		puts "\t\tdetails:"
#		puts "\t\tsignal hash #{sh}"
#		puts "\t\tdiv factor #{div_factor}"
#		puts "\t\tnormdist #{nd}"
		out = sh * ((nd * 2) / div_factor) / sh
#		puts "\t\ttotal #{out}"
		out
	rescue
		0
	end
end

(0..(joke_num-1)).each do |j|
	(0..(node_num-1)).each do |n|
		if (rand) < 0.005
			signal_hash[[j,n]] = 1
			puts "t"
		else
			signal_hash[[j,n]] = 0
			puts "f"
		end
	end
end


go=true

t=0
while (go==true)
go=false
t=t+1
outinfo = ""
activated = false
#(0..(joke_num-1)).each do |j|
#k = signal_hash.keys.select{|x| x.first == j}.select{|k| signal_hash[k] != 0}.size
#if k > 0
#	puts "not empty? #{k}"
#	outinfo = outinfo + ",#{k}"
#else
#	outinfo = outinfo + ",0"
#end
#end
nodes.each_index do |node|
	activated = false
	puts "entering on node #{node}"
	sig = 0
	jokes.each_index do |jk|
		sig = sig + signal_hash[[jk,node]]
	end
#	puts "signal total of #{sig}"
	jokes.each_index do |jk|
#		puts "\tlooking at node #{node} joke #{jk}"	
		activation = act_fun(node,jk,sig,signal_hash,nodes,jokes)
#		puts "\tactivation total of #{activation}"
		if (rand) < activation #activated
			activated = true
			nodes.each_index do |second_node|
				if (rand) < weight_hash[[node,second_node]]
					signal_hash[[jk,second_node]] = signal_hash[[jk,second_node]] + 1
#					outinfo = outinfo + ",1"
					sig = sig + 1
					go=true
					puts "\t\tsending signals to node #{second_node}"
#					puts "\t\tsignal for node is now #{signal_hash[[jk,second_node]]}"
				else
#					outinfo = outinfo + ",0"
				end
			end
		end
	end
	if activated
		outinfo = outinfo + "1,"
	else
		outinfo = outinfo + "0, "
	end
end
csv_file.puts "#{outinfo}"
end

csv_file.close
#edge_w.close
