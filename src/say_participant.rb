module Maestro
  class SayParticipant < Maestro::RuotePseudoParticipant
   def say
     `echo hello`
   end 
  end
end