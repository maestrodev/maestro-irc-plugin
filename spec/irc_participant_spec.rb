# Copyright 2011© MaestroDev.  All rights reserved.

#require 'spec_helper'
require 'isaac'

require 'src/irc_participant'

describe Maestro::IrcParticipant do

  describe 'consume()' do
    before(:all) do

      @test_participant = Maestro::IrcParticipant.new

    end

    after(:all) do
    end

    it 'should say a message' do
      #fields = { 'body' => 'adios terd nugget, your composition is complete'}
      wi = Ruote::Workitem.new({"fields" => {"body" => "testing"}, "params" => {"composition_task_id" => 1}})
      bot = mock()
      Maestro::Irc.stubs(:bot => bot)
      bot.stubs(:start => true)

      bot.stubs(:quit => true)
      #channel = mock(:channel)
      #channel.stubs(:say => true)
      bot.stubs(:message)

      @test_participant.stubs(:reply_to_engine)
      
      @test_participant.consume(wi)

      wi.fields['__error__'].should eql('')
    end

    it 'should throw execption with an IRC connection error' do
      wi = Ruote::Workitem.new({"fields" => {"body" => "testing"}})
      bot = stub_everything
      Maestro::Irc.stubs(:bot).returns bot

      Maestro::ReceiveError.stubs(:new => Exception.new("an exceptions"))

      context = mock()
      error_handler = mock()
      error_handler.stubs(:action_handle)
      context.stubs(:error_handler => error_handler)
      @test_participant.stubs(:current_context => context)


      bot.stubs(:message).raises(RuntimeError)
      @test_participant.stubs(:reply_to_engine)
      @test_participant.consume(wi)
      wi.fields['__error__'].should include('Failed to shout to IRC')
    end

    describe 'template' do

      it 'should create body from template' do
        composition = Composition.create(:name => "Template Test", :description => "Template Test")
        run = Run.create(:composition_id => composition[:id], :name => "Some Run", :source => {}.to_json, :trigger_type => "manual")
        wi = Ruote::Workitem.new({"fields" => {"composition_id" => composition[:id],"body" => "testing", "run_id" => run[:id],
           "url" => File.join(File.dirname(__FILE__), "../../lib/maestro/part/templates/irc.txt.erb")}, "params" => {"composition_task_id" => 1}})
        bot = mock()
        Maestro::Irc.stubs(:bot => bot)
        bot.stubs(:start => true)

        bot.stubs(:quit => true)

        bot.stubs(:message)

        @test_participant.stubs(:reply_to_engine)
      
        @test_participant.consume(wi)

        wi.fields['output'].should contain('[Template Test] Manually Executed')
        wi.fields['__error__'].should eql('')
      end

    end
  end
end