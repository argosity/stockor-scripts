class Query

  def initialize( lb, path )
      @lb   = lb
      @path = path
      @include = []
      @params = {}
  end

  def arguments( params )
      @params = @params.merge( params )
      self
  end

  def filter( params )
      @params[:filter ] = params
      self
  end

  def include( assoc )
      @include += [ *assoc ]
      self
  end

  def limit( num )
      @params[:limit] = num
      self
  end

  def results( &block )
      params = @params.merge({ :include=>@include } )
      @lb.execute( :get, @path, :params=>params, &block )
  end

  def data( &block )
      results( &block ).data
  end

end
