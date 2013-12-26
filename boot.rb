root = File.expand_path('..', __FILE__)
$:.unshift root
$:.unshift File.join(root, 'lib')

# Provides SSL root certificates for Faraday
# source: http://curl.haxx.se/ca/cacert.pem
ENV['SSL_CERT_FILE'] = File.join(root, 'cacert.pem')
