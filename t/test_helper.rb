CJSON = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/countries.json'.freeze
SHA   = 'd8a4682f'.freeze

def cjson_src
  CJSON % SHA
end
