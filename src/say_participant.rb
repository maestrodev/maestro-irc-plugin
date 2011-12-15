module MaestroWorker
  class SayParticipant < MaestroWorker::RuotePseudoParticipant
   def say
     `echo hello`
   end 
  end
end