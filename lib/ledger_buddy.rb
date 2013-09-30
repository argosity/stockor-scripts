require 'hashie'
require 'active_support/core_ext/hash'
require 'oj'
require 'yaml'
require 'base64'
require 'oauth2'
require 'rest_client'
require 'trollop'
require 'highline'
require 'httmultiparty'
require_relative 'query'

class LedgerBuddy

    attr_reader :http

    def initialize( token, options={} )
        @http    = token
        @options = options
        @address = options['address']
    end

    def get( subpath )
        Query.new( self, subpath )
    end

    def upload( subpath, params )
        url = address + url_for(subpath)
        return HTTMultiParty.post( url, :body=>params.merge({'access_token'=>@http.token.to_s } ) )
    end

    def delete( subpath, id, &block)
        self.execute(:delete, subpath.to_s + '/' + id.to_s, {}, &block )
    end

    def update( subpath, id, attrs, &block )
        self.execute(:put, subpath.to_s + '/' + id.to_s, :body=>{ 'data'=>attrs.stringify_keys }, &block )
    end

    def create( subpath, data, params={}, &block )
        self.execute(:post, subpath, { :body=>{ 'data' => data.stringify_keys }, :params=>params }, &block )
    end

    def address
        @http.client.site
    end

    def url_for( subpath )
        "api/#{subpath}"
    end

    def execute( method, path, opts, &block )
        begin
            resp = @http.request(
                method,
                self.url_for(path),
                opts
                )
            if resp.status == 200
                Hashie::Mash.new Oj.load resp.body
            else
                raise resp.status_line
            end
        rescue OAuth2::Error=>e
            raise "#{e.response.status} error: #{e.response.body}"
        end
    end


    def self.from_command_line( opts={} )
        settings = File.exists?(".settings.yml") ? YAML.load( File.open(".settings.yml") ) : {}
        opts.merge!( settings.symbolize_keys )
        cmdline_opts = Trollop::options do
            opt :server, "Server Address", :type=>:string, :default=>opts[:server], :required => ! opts.has_key?(:server)
            opt :client_id, "OAuth2 client_id", :type=>:string, :default=>opts[:client_id], :requied => ! opts.has_key?(:client_id)
            opt :client_secret, "OAuth2 client secret key", :type=>:string, :default=>opts[:client_secret], :requied=> ! opts.has_key?(:client_secret)
            opt :token, "OAuth2 access token"
            opt :username, "username for login/pw authentication", :type=>:string
            opt :password, "password to use",   :type=>:string
        end
        opts.merge!(cmdline_opts)

        server = opts[:server]
        server = "http://#{server}/" unless server=~/^http/

        client = OAuth2::Client.new( opts[:client_id], opts[:client_secret], :site => server )

        if opts[:username].present? && opts[:password].present?
            verfier = client.password.get_token( opts[:username], opts[:password] )
            token = OAuth2::AccessToken.new( client, verfier.token ).token
        elsif ! settings['token']
            redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
            url = client.auth_code.authorize_url(:redirect_uri => redirect_uri )
            `open "#{url}"`
            hl = HighLine.new
            token = hl.ask("Enter token from website:  ") { |q| q.echo = "x" }
            token = client.auth_code.get_token( token.to_s, { :redirect_uri => redirect_uri }).token
        end
        File.open(".settings.yml", "w") do |file|
            settings['token'] = token.to_s
            file.write settings.to_yaml
        end
        LedgerBuddy.new( OAuth2::AccessToken.new( client, token ), settings )
    end


end
