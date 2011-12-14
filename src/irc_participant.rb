# Copyright 2011© MaestroDev.  All rights reserved.

require 'irc'

module MaestroWorker
  class IrcParticipant < MaestroWorker::RuotePseudoParticipant
          
    def lines
      
      begin
        url = workitem['fields']["url"]
        MaestroWorker.log.debug("Attempting To Load IRC Template From #{url}")
        begin
        template = File.open(url)
        rescue Exception => e
          MaestroWorker.log.warn("Failed To Load IRC Template From File, #{e}")
          raise "Failed To Load IRC Template From File #{e}"
        end
        MaestroWorker.log.debug("Loaded IRC Template From #{url}")
        renderer = ERB.new(template.readlines.join(''))
        lines = renderer.result(binding).andand.split(/^/).delete_if{|line| line.gsub(/\s*/, '').empty?}
      rescue Exception => e
        MaestroWorker.log.debug("Using Body As String #{e}")
        lines = (!body.nil? ? body : "No Body Set For Message").split(/^/)
      end
    end

    def notify
      begin
        MaestroWorker.log.info "Posting Message To IRC"
        workitem['fields']['output']=''
        lines.each do |line|
          MaestroWorker.log.debug "Sending Line #{line}" if !line.gsub(/\s*/, '').empty?
          MaestroWorker::Irc.bot.message line if !line.gsub(/\s*/, '').empty?
        end

        # workitem['fields']['output']=("Posted Messages #{lines.join(' ')}")
        write_output("Posted Messages #{lines.join(' ')}")

        MaestroWorker.log.info "Completed Posting Message To IRC"
      rescue RuntimeError => e
        MaestroWorker.log.error "ERROR: Failed to shout to IRC - #{e}"
        workitem['fields']['__error__'] = "ERROR: Failed to shout to IRC - #{e}"
        return
      end
      workitem['fields']['__error__'] = ''
      
    end
  end
  
end


