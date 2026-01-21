
  def step str=nil
    puts str || "stepping (hit a key)"
    $stdin.gets
  end
