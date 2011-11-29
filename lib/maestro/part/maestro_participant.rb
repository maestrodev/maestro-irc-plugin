# Copyright 2011© MaestroDev.  All rights reserved.

require 'maestro/part/context'

module Maestro
  class MaestroParticipantException < Exception
  end
  
  
  module MaestroParticipantMixin
    include Ruote::LocalParticipant 
    include Maestro::CompositionHelper
    include Maestro::ContextMixin
    
    # def output=(output)
    #   if workitem.class == Hash
    #     workitem["fields"]["output"] = output
    #   else
    #     workitem.fields["output"] = output
    #   end
    # end
    # 
    # def output 
    #   case workitem.class
    #   when Hash
    #     return workitem["fields"]["output"]
    #   else
    #     return workitem.fields["output"]
    #   end
    # end

    def retryable(options = {}, &block)
      opts = { :tries => 1, :on => Exception, :wait => 5 }.merge(options)

      retry_exception, retries, wait = opts[:on], opts[:tries], opts[:wait]

      begin
        return yield
      rescue retry_exception
        Maestro.log.warn "Failed To Connect On After Attempt"
        sleep wait
        retry if (retries -= 1) > 0
      end

      yield
    end

    def stream_output(new_output)
      Thread.exclusive do
        # if new_output.andand.size > 10E4
        #   # 0.step(new_output.andand.size, 10E4).each do |index|
        #   #   size = (new_output.andand.size - index) > 10E4 ? 10E4 : new_output.andand.size - index
        #   #   line = new_output[index, size]
        #   #   puts "writing line #{line}"
        #     persist_output_to_file(new_output, false)
        #   # end
        # else
          persist_output(new_output, false)
        # end
      end
    end
    alias :write_output :stream_output

    def persist_output_to_file(run_output, run, task_run_output, task_run)
      
       run_filename = "/tmp/maestro_run_#{run[:id]}.log"
       task_run_filename = "/tmp/maestro_task_run_#{task_run[:id]}.log"
       File.open(run_filename, 'w') {|f| f.write(run_output) }
       File.open(task_run_filename, 'w') {|f| f.write(task_run_output) }
       
       
       task_run.update(:output => task_run_filename)

       run.update(:output => run_filename)
    end
    
    def persist_output_to_database(run_output, run, task_run_output, task_run)
      run.andand.output = run_output
      run.andand.save

      task_run.andand.output = task_run_output
      task_run.andand.save
    end
    
    def persist_output(new_output, truncate = true)
      
      Thread.exclusive do
        if (@workitem || workitem).class.to_s == "Hash"
          fields = (@workitem['fields'] || workitem['fields'])
        else
          fields = (@workitem || workitem).fields
        end
      
        fields['output'] = fields['output'].nil? ? new_output : fields['output'] + new_output
      
        task_run = TaskRun.get(fields['task_run_id'])
        run = Run.get(fields['run_id'])

        if !truncate
          task_run_output = (task_run.andand.output || '') 
          task_run_output += new_output || ''
          run_output = (run.andand.output || '')
          run_output += new_output || ''        
        else
          run_output = task_run_output = new_output
        end    
        
        if(run_output.size > 1E6)
          persist_output_to_file(run_output, run, task_run_output, task_run)
        else
          persist_output_to_database(run_output, run, task_run_output, task_run)
        end
      
        [run_output, task_run_output]
      end
    end
    
    # def error=(error)
    #      if workitem.class.to_s == "Hash"
    #        fields = workitem["fields"]
    #      else
    #        fields = workitem.fields
    #      end
    #      fields["__error__"] = error
    #       
    #      persist_output(error)
    #      
    #      error || ''
    #    end
    #    
    #    def error 
    #      if workitem.class.to_s == "Hash"
    #        fields = workitem["fields"]
    #      else
    #        fields = workitem.fields
    #      end
    #      error = fields["__error__"] = fields["__error__"] || ''
    # 
    #      error 
    #    end
    #    
    #    def add_error(error)
    #      if workitem.class.to_s == "Hash"
    #        fields = workitem["fields"]
    #      else
    #        fields = workitem.fields
    #      end
    #      
    #      fields["__error__"] = '' if fields["__error__"].nil?
    #      
    #      error = fields["__error__"] += error
    #      
    #      persist_output(error, false)
    #      
    #      error || ''
    #    end
    # 
    #    def output=(output)
    #      if workitem.class.to_s == "Hash"
    #            fields = workitem["fields"]
    #          else
    #            fields = workitem.fields
    #          end
    #          fields["output"] = output
    #       
    #      persist_output(output)
    #      
    #      output || ''
    #    end
    #    
    #    def output 
    #      if workitem.class.to_s == "Hash"
    #        fields = workitem["fields"]
    # 
    #      else
    #        fields = workitem.fields
    #      end
    #      output = fields["output"] = fields["output"] || ''
    # 
    #      output 
    #    end
    #    
    #    def add_output(output)
    #      if workitem.class.to_s == "Hash"
    #        fields = workitem["fields"]
    #      else
    #        fields = workitem.fields
    #      end
    #      
    #      fields["output"] = '' if fields["output"].nil?      
    #      
    #      fields["output"] += output
    # 
    #      
    #      persist_output(output, false)
    #      
    #      fields["output"]
    #    end

    
    def current_context
      @context
    end
    
    def handle_error(err, werk)
      werk.fields['__error__'] = err.to_s

      
      Maestro.log.error "Error executing participant \n #{err.backtrace if err.respond_to?('backtrace')}"
      run = Run.get(werk.fields['run_id'])
      
      begin
        current_context.andand.error_handler.action_handle(
          'error', werk.to_h["fei"], ReceiveError.new(werk.to_h["fei"], werk.to_h['fields']["__error__"])
        ) if RuoteKit.engine and run.andand.state
      rescue        
      end
      Agent.get(run.andand.agent_id).andand.update(:busy => false)
      
      persist_end(werk)
      
      
      
      # if run and run.andand.composition.andand.on_error.nil? and !run.andand.is_scheduled?
      #   RuoteKit.engine.kill(run.workflow_id)
      # end
    end
    
    def determine_run_state(workitem, wfid, state)
      
      workitem = workitem.to_h if workitem.is_a? Ruote::Workitem
      Maestro.log.debug("Determing State Checking If - #{state}")      
      
      new_state = State::RUNNING
 
      @run = Run.last(:workflow_id => wfid)        
      return @run.state unless @run.nil? or @run.state == State::RUNNING or @run.state == State::WAITING
 
      @composition = @run.composition
      
      task_runs = @run.task_runs
      
      if state == State::COMPLETE and !workitem['fields']['__retry__']
        
        Maestro.log.debug("Determine State COMPLETE - #{new_state}")
        composition_tasks = @composition.composition_tasks
        running = composition_tasks.size > task_runs.size
        Maestro.log.debug("Currently #{task_runs.size}/#{composition_tasks.size} Tasks Have Started")
        
        complete_count = 0
        task_runs.each do |task_run|
          complete_count += 1 if task_run.state == State::COMPLETE
        end
        Maestro.log.debug("Currently #{complete_count}/#{composition_tasks.size} Tasks Have Completed")
        new_state = State::COMPLETE if !running
        
        task_runs.each {|task_run| new_state = task_run.state if task_run.state == State::FAILED || task_run.state == State::CANCELED || task_run.state == State::KILLED}
        #task_runs.each {|task_run| new_state = State::WAITING if task_run.state == State::WAITING}
	      wait_flag = false
	      run_flag = false
	      task_runs.each do |task_run|
      		if task_run.state == State::WAITING
		         wait_flag = true
      		elsif task_run.state == State::RUNNING
		         run_flag = true
		      end
	      end
	      new_state = State::WAITING if wait_flag && !run_flag
        Maestro.log.debug("Determine State new_state - #{new_state}")

      elsif (state == State::CANCELED or state == State::FAILED) and @composition.on_error.nil? and !workitem['fields']['__retry__']
        Maestro.log.debug("Determine State CANCELED or FAILED - #{new_state}")
        new_state = state
       # task_runs.each {|task_run| new_state = State::WAITING if task_run.state == State::WAITING}
     	  wait_flag = false
 	      run_flag = false
	      task_runs.each do |task_run|
		      if task_run.state == State::WAITING
		         wait_flag = true
		      elsif task_run.state == State::RUNNING
		        run_flag = true
		      end
	      end
	      new_state == State::WAITING if wait_flag && !run_flag

        Maestro.log.debug("determine state new_state - #{new_state}")
      end
      
      Maestro.log.debug("Determinied new_state - #{new_state}")      
      new_state
    end
    
    def persist_run(wfid, composition)
      return if RuoteKit.engine.nil?
      
      @run = Run.first(:workflow_id => wfid)
      @run = Run.from_composition_with_workflow_id(composition, wfid, false) if @run.nil?
      
    end
    
    def populate_workitem_with_run(workitem, run)
      workitem.fields['composition_id'] = run.composition_id
      workitem.fields['input'] = run.source if !run.source.nil?
      workitem.fields['trigger_type'] = run.trigger_type if !run.trigger_type.nil?
      workitem.fields['message'] = run.message if !run.message.nil?
      workitem.fields['user'] = run.user if !run.user.nil?
      workitem.fields['username'] = run.username if !run.username.nil?
      workitem.fields['passcode'] = run.passcode if !run.passcode.nil?
      workitem.fields['hostname'] = run.hostname if !run.hostname.nil?
      workitem.fields['domain'] = run.domain if !run.domain.nil?
      workitem.fields['run_id'] = run.andand[:id]
    end
    
    def update_run(workitem, wfid, state, output)

      @run = Run.last(:workflow_id => wfid)
          return if @run.nil?
                
      state = determine_run_state(workitem, wfid, state)
      @run.save
      @run.update(:state => state)
      
      process_status = RuoteKit.engine.andand.process(@run[:workflow_id])
      errors = []

      process_status.errors.each do |error|
        errors << error.message
      end if process_status
      
      # @run.update(:output => @run.output.to_s + output.to_s + (errors.size > 0 ? errors.to_json : "\n"))
     
      # @run.update(:output => @run.output + output + (errors.size > 0 ? errors.to_json : "\n"))
      # add_output(@run.output + output + (errors.size > 0 ? errors.to_json : "\n"))
     
      # if State::is_finished_not_canceled?(state) and @run.is_scheduled?
      #   puts "#{state}"
      #   run = Run.create(@run.attributes.merge(:id => nil, :output => '', :created_at => @run.updated_at, :state => State::SCHEDULED)) 
      #   puts "#{state}"
      #   Maestro.log.debug "Existing Run [#{@run[:id]}] Is #{@run[:state]}, Creating A New Run [#{run[:id]}] For #{run[:state]} Composition"     
      # end
    end
     
    def persist_start(workitem)
    Thread.exclusive do
      if(workitem.params.andand['composition_task_id'])
        run = Run.last(:workflow_id => workitem.wfid) if RuoteKit.engine
        composition_task = CompositionTask.get(workitem.params['composition_task_id'])        
        
        populate_workitem_with_run(workitem, run) if run
        
        @task_run = TaskRun.create(:name => composition_task.task.name,
                        :description => composition_task.task.description,
                        :state => State::RUNNING,
                        :position => composition_task.position,
                        :workitem => workitem.to_h.to_json,
                        :options => composition_task.options,
                        :composition_task_id => composition_task['id'],
                        :workflow_id => workitem.wfid,
                        :run_id => run[:id])

        raise "Invalid Data For Start Of Task #{@task_run.to_json}" unless @task_run.valid?
        
        Maestro.log.debug("Persisting Start Of Task Run #{@task_run[:name]}")
        
        @task_run.update(:agent_id => workitem.fields['agent_id']) if workitem.fields['agent_id']
        
        workitem.fields['task_run_id'] = @task_run[:id]

        persist_run(workitem.wfid, composition_task.composition) if Run.all(:workflow_id => workitem.wfid ).
          size == 0
        
        update_run(workitem, @task_run.workflow_id, State::RUNNING, @task_run.output)
      end
    end
    end
    
    def persist_end(workitem)
    Thread.exclusive do    

      workitem = workitem.to_h if workitem.is_a? Ruote::Workitem
      
      workitem['fields']['__error__'] = workitem['fields']['__error__']['message'] if workitem['fields']['__error__'].class == Hash
      error =  workitem['fields']['__error__']
      
      @task_run = TaskRun.get(workitem['fields']['task_run_id'])
      return if @task_run.nil?
      
      Maestro.log.debug("Persisting End Of Task Run #{@task_run[:name]}")
      
      state = State::RUNNING      
      if(defined? @task_run and @task_run)
        if(!error.nil? and !error.empty?)
          @task_run.update(:state => State::FAILED)
          begin
            write_output("Maestro Detected An Error - #{error}")
          rescue Exception => e
            Maestro.log.error "Error - #{e}"
          end
          state = State::FAILED
        else
          if @task_run.state == State::KILLED or @task_run.state ==  State::CANCELED
            state = @task_run.state
          else
            state = State::COMPLETE
            @task_run.update(:state => state)
            # persist_output(workitem['fields']['output'].class == String ? Iconv.new('US-ASCII//IGNORE', 'UTF-8').iconv(workitem['fields']['output'] ) : workitem['fields']['output'], false)
          end
        end
      end

      update_run(workitem, @task_run.workflow_id, state, @task_run.output)
      
      workitem['fields']['output'] = ''
      workitem['fields']['input'] = ''
    end
    end
    
    # Implemented in each participant
    def work
      raise Exception.new 'Not implemented!'
    end
    
  end
  
  class MaestroParticipant
    include MaestroParticipantMixin
    
    def initialize 
      @work_and_reply = true
    end
    
    attr_accessor :workitem
    attr_accessor :work_and_reply
    
    def consume(workitem)
      begin
        Maestro.log.debug "Consuming Workitem"
        @workitem = workitem
          persist_start(@workitem)

          workitem.fields.each do |field, value|
            workitem.fields[field] = evaluate_field(value) unless field.match(/\_id/) or field.match(/\_\_/)
          end

          Maestro.log.debug "Performing Work"                  
          work
        
          raise @workitem.fields['__error__'] if !@workitem.fields['__error__'].nil? and !@workitem.fields['__error__'].empty?
          
          if work_and_reply
            run = Run.get(@workitem.fields['run_id'])

            persist_end(@workitem)
          
            Maestro.log.debug "Replying To Engine With Workitem #{@workitem.to_h.to_json}"        
            reply_to_engine(@workitem) 
          end
      rescue Exception => e
        handle_error(e,@workitem)
      end
      
    end
    
    
    
    def cancel(fei, flavour)
      @workitem = RuoteKit.engine.process(fei.wfid).workitems[0] # uncomfortable
      @workitem = @workitem.to_h if @workitem.is_a? Ruote::Workitem 
    
      task_runs = TaskRun.all(:workflow_id => fei.wfid, :state.not => State::COMPLETE) &
                   TaskRun.all(:workflow_id => fei.wfid, :state.not => State::FAILED)
      task_runs.update(:state => flavour == 'kill' ? State::KILLED : State::CANCELED)
      
      persist_end(@workitem)
    end
    
  end
end
