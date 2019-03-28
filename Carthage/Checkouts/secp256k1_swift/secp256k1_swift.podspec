Pod::Spec.new do |s|
s.name             = "secp256k1_swift"
s.version          = "1.0.2"
s.summary          = "Swift bindings for secp256k1 C library for iOS and OSX"

s.description      = <<-DESC
Swift bindings for secp256k1 C library for iOS and OSX for various applications
DESC

s.homepage         = "https://github.com/shamatar/secp256k1_swift"
s.license          = 'Apache License 2.0'
s.author           = { "Alex Vlasov" => "alex.m.vlasov@gmail.com" }
s.source           = { :git => 'https://github.com/shamatar/secp256k1_swift.git', :tag => s.version.to_s, :submodules => true }
s.social_media_url = 'https://twitter.com/shamatar'

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.10'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '2.0'
s.swift_version = '4.0'
s.module_name = 'secp256k1_swift'

s.prepare_command = <<-CMD
                        sed -i '' -e 's:include/::g' ./**/**/**/*.c
                        sed -i '' -e 's:include/::g' ./**/**/**/**/**/*.h
                   CMD

s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS' => '${PODS_ROOT}',
    'OTHER_CFLAGS' => '-DHAVE_CONFIG_H=1 -pedantic -Wall -Wextra -Wcast-align -Wnested-externs -Wshadow -Wstrict-prototypes -Wno-shorten-64-to-32 -Wno-conditional-uninitialized -Wno-unused-function -Wno-long-long -Wno-overlength-strings -O3',
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/secp256k1"'
}

s.source_files = 'Classes/secp256k1/{src,include,contrib}/*.{h,c}', 'Classes/secp256k1/src/modules/{recovery,ecdh}/*.{h,c}', 'Classes/libsecp256k1-config.h', 'Classes/secp256k1_main.h', 'Classes/secp256k1.swift'
s.public_header_files = 'Classes/secp256k1/include/*.h'
s.private_header_files = 'Classes/secp256k1/*.h', 'Classes/secp256k1/{contrib,src}/*.h', 'Classes/secp256k1/src/modules/{recovery, ecdh}/*.h'
s.exclude_files = 'Classes/secp256k1/src/test*.{c,h}', 'Classes/secp256k1/src/gen_context.c', 'Classes/secp256k1/src/*bench*.{c,h}', 'Classes/secp256k1/src/modules/{recovery,ecdh}/*test*.{c,h}', 'Classes/module.modulemap'

end
