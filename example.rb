require "csv"

class PlayerInfoDSL
    attr_reader :conditions
    def method_missing(m, *args, &block)
        <<-DOC
            method_missing is a method in Ruby that intercepts calls to methods that don’t exist. It handles any messages that an object can’t respond to.
        DOC
        
        where(m, args.first)
    end

    def query &block
        instance_eval(&block) #Allows to use the instance methods inside the block.
        data
    end

    def initialize(file_path)
        @conditions = {}
        @data = CSV.read(file_path, headers: true, header_converters: :symbol, converters: :all)
        
        @data = @data.collect do |row|
            Hash[row.collect { |key, value| [key, value]  }]            
        end       
    end

    def where property, expected
        @conditions[property] = expected        
    end

    def data
        results = @data.dup
        @conditions.each do |key, value|
          results = results.find_all do |row|
            row[key].to_s == value
          end
        end
        results
      end
    
      def flush
        @conditions = {}
      end
     

end

c = PlayerInfoDSL.new("data.csv")
# puts c.where(:country, "USA")
# puts c.country "Argentina"
# puts c.data
c.query do 
    country "Argentina"
    height '175'
end

puts c.data