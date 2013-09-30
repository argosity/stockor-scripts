class Query

  def initialize( lb, path )
      @lb   = lb
      @path = path
      @include = []
      @params = {}
  end

  def arguments( params )
      @params.merge!( params )
      self
  end

  def query( params )
      @params[:query ] = params
      self
  end

  def include( assoc )
      @params[:include] = [ *assoc  ]
      self
  end

  def limit( num )
      @params[:limit] = num
      self
  end

  def first
      data.first
  end

  def results( &block )
      @lb.execute( :get, @path, :params=>@params, &block )
  end

  def data( &block )
      results( &block ).data
  end

end
