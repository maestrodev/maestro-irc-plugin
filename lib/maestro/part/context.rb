module Maestro 
  module ContextMixin
    def change_hash_to_use_symbols(hash) 
       symbolized = {}
       hash.inject({}){|composition,(k,v)| symbolized[k.to_sym] = v; symbolized}
       symbolized
    end

    def composition
      composition = Composition.get((@workitem || workitem).fields['composition_id'])
      change_hash_to_use_symbols(JSON.parse(composition.to_json))
    end

    def run
      run = Run.get((@workitem || workitem).fields['run_id'])
      change_hash_to_use_symbols(JSON.parse(run.to_json))
    end

    def task_run
      run = TaskRun.get((@workitem || workitem).fields['task_run_id'])
      change_hash_to_use_symbols(JSON.parse(run.to_json))
    end

    def output
      run = Run.get((@workitem || workitem).fields['run_id'])
      return run.output if run.task_runs.nil? or run.task_runs.empty?
      task_runs = run.task_runs
      outputs = ''
      task_runs.each do |task_run|
        unless task_run[:id] == (@workitem || workitem).fields['task_run_id']

          outputs << "#{task_run['name']} #{task_run['state']} (#{task_run.duration}) \n #{task_run.output}\n"
        end
      end
      outputs
    end

    def fields
      change_hash_to_use_symbols((@workitem || workitem).fields)
    end

    def trigger
     begin
       change_hash_to_use_symbols(JSON.parse(Run.get((@workitem || workitem).fields['run_id']).source))
     rescue
       (@workitem || workitem).fields['input']
     end
    end

    def input
      (@workitem || workitem).fields['input']
    end

    def error
      (@workitem || workitem).fields['__error__']
    end

    def users_with_machines_older_than?(days_old)
     users.collect {|user| user if !user[:machines].empty? and !user[:machines].collect{|machine| machine if (Date.today - Date.parse(machine["created_at"])) > days_old }.delete_if{|machine|  machine.nil?}.empty?}.delete_if{|user| user.nil?}
    end

    def users
      users = []

      JSON.parse(User.all.to_json).each do |user|
        users << change_hash_to_use_symbols(user)
      end

      users
    end

    def field_is_json?(field)
      begin
        JSON.parse(field)
        return true
      rescue Exception
        return false
      end
    end
    
    def add_quotes(field)
      return '"' + field + '"' if field[0] != '"'
      return field
    end
    
    def evaluate_array(array)
      new_array = []
      array.each do |field|
        new_array << evaluate_expression(field)
      end
      return new_array
    end
    
    def evaluate_hash(hash)
      new_hash = []
      
      hash.each do |field, value|
        new_hash[field] = evaluate_expression(value)
      end
    end
    
    def evaluate_expression(string)
      errors = []
      
      ['unquoted','quoted','find_and_replace'].each do |try|
        begin
          if(try == 'find_and_replace')
            string.scan(/\#\{[\s\+\w\[\]\:\_\'\"]*\}/i) do |el|
              ruby = el.to_s.gsub(/\#\{/, '').gsub(/\}/,'')
              evaluated = eval(ruby)
              raise "Field Evaluated To Unsupported Object #{evaluated.class.to_s}" if evaluated.class.to_s != "String"
              string = string.gsub(el, evaluated)
            end
            return string
          else
            new_string = (try == 'quoted' ? add_quotes(string) : string)
            evaluated = URI.decode(eval(new_string))
            Maestro.log.debug("Field Evaluated To #{evaluated}")
            raise "Field Evaluated To Unsupported Object #{evaluated.class.to_s}"  if evaluated.class.to_s != "String"
            return evaluated
          end
        rescue Exception => e
          errors << e
        end
      end unless string.class.to_s != 'String' or string.nil? or string.empty?
      
      Maestro.log.debug "Evaluate Failed Evaluating Field #{string.to_json}, Using As-Is #{errors.join(', ')}"
      return string
    end
    
    
    def evaluate_field(field)
      return if field.nil?

      begin
         new_field = field_is_json?(field) ? JSON.parse(field) : field 
         
         case new_field.class.to_s
         when 'String'
           Maestro.log.debug("Attempting To Evaluate Field As String #{new_field}")           
           return evaluate_expression(new_field)
         when 'Hash'
           Maestro.log.debug("Attempting To Evaluate Field As Hash #{new_field.to_json}")           
           return "#{evaluate_hash(new_field).to_json}"
         when 'Array'
           Maestro.log.debug("Attempting To Evaluate Field As Array #{new_field.to_json}")                      
           return "#{evaluate_array(new_field).to_json}"
         end
       rescue Exception => e
         Maestro.log.debug "Failed Evaluating Field #{field.to_json}, Using As-Is #{e}"
         return field
       end
    end
  end
  
  
  class Context
    include ContextMixin
    
  end
end