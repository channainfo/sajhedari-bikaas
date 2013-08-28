class Sms
  attr_accessor :nuntium, :from, :body, :to, :channel

  def initialize &block
    if block_given?
      if block.arity == 1 # pass an argurment that is a class instance
        yield self
      else #evaluate the block in the context of the class instance
        self.instance_eval &block
      end
    end
  end
  
  def body(val)
    @body = val
  end
  
  def to(val)
    @to = val
  end
  
  def from(val)
    @from = val
  end

  def channel(val)
    @channel = val
  end

  def send
    nuntium = Nuntium.new_from_config
    nuntium.send_ao(:from => @from, :to => "sms://#{@to}", :body => @body, :suggested_channel => @channel)
    Sms.log @from, @to , @body, @channel
  end
  
  def to_hash
    {:to => @to, :from => @from, :body => @body, :channel => @channel}
  end
  
  
  def self.log from, to, body, channel
    Rails.logger.info "\n-------- Start send Sms job log ---------------------------"
    Rails.logger.info ":from => #{from}, :to => #{to}, :body => #{body}, #{channel}"
    Rails.logger.info "-------- End send Sms job log -----------------------------\n"
  end
  
  class << self
    attr_accessor :from, :body, :to, :channel
    def body(val)
      @body = val
    end

    def to(val)
      @to = val
    end

    def from(val)
      @from = val
    end

    def channel(val)
      @channel = val
    end

    def send &block
      if block_given?
        if block.arity == 1 
          yield self
        else
          self.instance_eval(&block)
        end
      end
      nuntium = Nuntium.new_from_config
      nuntium.send_ao(:from => @from, :to =>  "sms://#{@to}", :body => @body, :suggested_channel => @channel)
      Sms.log(@from, @to, @body, @channel)
      self
    end
    
    def to_hash
      {:from => @from, :to => @from, :body =>  @body, :channel => @channel}
    end
  end
  
end
