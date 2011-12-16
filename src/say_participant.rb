module Maestro
  class SayParticipant < Maestro::MaestroWorker
   def say
     `echo hello`
   end 
  end
end