# Copyright 2011© MaestroDev.  All rights reserved.

require 'maestro/part/notification_participant'
require 'isaac/bot'

module Maestro
  class IrcParticipant < NotificationParticipant
          
    def lines
      
      begin
        url = workitem.fields["url"]
        Maestro.log.debug("Attempting To Load IRC Template From #{url}")
        begin
        template = File.open(url)
        rescue Exception => e
          Maestro.log.warn("Failed To Load IRC Template From File, #{e}")
          raise "Failed To Load IRC Template From File #{e}"
        end
        Maestro.log.debug("Loaded IRC Template From #{url}")
        renderer = ERB.new(template.readlines.join(''))
        lines = renderer.result(binding).andand.split(/^/).delete_if{|line| line.gsub(/\s*/, '').empty?}
      rescue Exception => e
        Maestro.log.debug("Using Body As String #{e}")
        lines = (!body.nil? ? body : "No Body Set For Message").split(/^/)
      end
    end

    def work
      begin
        Maestro.log.info "Posting Message To IRC"
        workitem.fields['output']=''
        lines.each do |line|
          Maestro.log.debug "Sending Line #{line}" if !line.gsub(/\s*/, '').empty?
          Maestro::Irc.bot.message line if !line.gsub(/\s*/, '').empty?
        end

        # workitem.fields['output']=("Posted Messages #{lines.join(' ')}")
        write_output("Posted Messages #{lines.join(' ')}")

        Maestro.log.info "Completed Posting Message To IRC"
      rescue RuntimeError => e
        Maestro.log.error "ERROR: Failed to shout to IRC - #{e}"
        workitem.fields['__error__'] = "ERROR: Failed to shout to IRC - #{e}"
        return
      end
      workitem.fields['__error__'] = ''
      
    end
  end
  
end


