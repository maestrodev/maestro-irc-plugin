require 'erb'
require 'maestro/part/maestro_participant'
require 'maestro/part/context'

module Maestro
  class NotificationParticipant < MaestroParticipant   

   def body
     evaluate_field(workitem.fields['body'].gsub(/body/,"'body'")) unless workitem.fields['body'].nil?
   end
   
   def subject
     evaluate_field(workitem.fields['subject'].gsub(/subject/,"'subject'")) unless workitem.fields['subject'].nil?
   end
   
   def to
     begin
       JSON.parse workitem.fields['to'] unless workitem.fields['to'].nil?
     rescue
       evaluate_field(workitem.fields['to'].gsub(/to/,"'to'")) unless workitem.fields['to'].nil?
     end
   end
   
 end
end