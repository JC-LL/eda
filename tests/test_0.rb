require_relative "../lib/eda"

$verbose=false

raise "need 3 args (nb eqs, nb vars, circuit depth)" unless ARGV.size==3

nb_eqs,nb_vars,depth=ARGV[0..2].map(&:to_i)

tool=EDA::Tool.new

vars=tool.gen_random_vars(nb_vars)

eqs=tool.gen_random_equations(nb_eqs,vars,depth)

circuit=tool.elab_circuit("test_0",eqs)

tool.report_stats(circuit)
tool.gen_dot(circuit)
tool.gen_vhdl(circuit)
tool.static_analysis_min_max(circuit)
tool.insert_buffer_random(circuit)
tool.gen_dot(circuit,"after_insertion.dot")
