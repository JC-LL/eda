require_relative "../lib/eda"

test_name="test_3"

raise "need 3 args (nb eqs, nb vars, circuit depth)" unless ARGV.size==3
nb_eqs,nb_vars,depth=ARGV[0..2].map(&:to_i)

tool=EDA::Tool.new

vars=tool.gen_random_vars(nb_vars)
eqs=tool.gen_random_equations(nb_eqs,vars,depth)

circuit=tool.elab_circuit(test_name,eqs)
tool.report_stats(circuit)
tool.gen_dot(circuit)

# serialization
sxp_filename=tool.write_sxp(circuit)

buffer=tool.insert_buffer_random(circuit,delay=1)
