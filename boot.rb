root = File.expand_path('..', __FILE__)
$:.unshift root
$:.unshift File.join(root, 'lib')

ENV['SSL_CERT_FILE'] = File.join(root, 'cacert.pem')
