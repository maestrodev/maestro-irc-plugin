module MaestroWorker
  class SayParticipant < MaestroWorker::RuotePseudoParticipant
   def say
     `say hello`
   end 
  end
end