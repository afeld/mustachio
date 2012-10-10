Magickly.dragonfly.configure do |c|
  # c.log_commands = true
  
  c.analyser.add :face_data do |temp_object|
    Mustachio.face_data(temp_object)
  end
  
  c.analyser.add :face_data_as_px do |temp_object, width, height|
    Mustachio.face_data_as_px(temp_object, width, height)
  end
  
  c.analyser.add :face_span do |temp_object|
    Mustachio.face_span(temp_object)
  end
  
end
