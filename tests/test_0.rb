require_relative "../lib/eda"

$verbose=false
nb_eqs,nb_vars,depth=ARGV[0..2].map(&:to_i)

tool=EDA::Tool.new

vars=tool.gen_random_vars(nb_vars)

eqs=tool.gen_random_equations(nb_eqs,vars,depth)

circuit=tool.elab_circuit("test_0",eqs)

tool.report_stats(circuit)
tool.print_dot(circuit)
