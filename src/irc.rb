# Copyright 2011© MaestroDev.  All rights reserved.

require 'uuid'
require 'isaac/bot'

module MaestroWorker
  class Irc
    
    @@irc = nil
    @@connected = false
    @@chan = nil
    
    @bot = nil
    
    def initialize
      @@connected = false
      
      @semaphore = Mutex.new

      Thread.new do
        @bot = Isaac::Bot.new do

          configure do |c|
          
            # config = Maestro.irc_config
            # create a "random" nick so we don't have to worry about handling names
            c.nick = ("Maestro_") + "-" +UUID.new.generate
            c.server = "irc.freenode.net"
            c.password = ""
            c.ssl = false
            c.port = 6667
          
          end

          on :connect do
            @@chan = "#kittest"
            join @@chan
            @@connected = true
          end
          
          on :private do
            puts 'message!'
          end
          
        end 
        
        
        begin
          @bot.start
        rescue Exception
          MaestroWorker.log.info "Closed IRC connection to #{@bot.host}"
        end  
        
      end
    end
    
    def connected?
      @@connected
    end
    
    def message(what_should_i_say)
      begin
        thread = Thread.new do
          while !connected?
            sleep(4)
          end

          @semaphore.synchronize do
              @bot.msg @@chan, what_should_i_say
              # sleep(2)
          end
        end
        thread.join
      rescue Exception
        MaestroWorker.log.error "Error sending message to IRC"
      end
    end    
    
    class << self
      def bot(config)
        @@irc = Irc.new(config) if @@irc.nil?
        
        @@irc
      end
              
    end
  end
  
  class IrcMessage
    class << self
      
      def set_body(body = "I am an IRC message")
        @@body = body
      end
      
      def get_body
        @@body
      end
            
    end
  end
end