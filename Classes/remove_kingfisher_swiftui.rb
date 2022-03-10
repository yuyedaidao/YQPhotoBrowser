# 解决 xcode13 Kingfisher Release模式下SwiftUI报错问题
puts "-------------------->>>"
system("pwd")
system("ls Pods/Kingfisher/Sources/General")
system("rm -rf Pods/Kingfisher/Sources/SwiftUI")
code_file = "Pods/Kingfisher/Sources/General/KFOptionsSetter.swift"
code_text = File.read(code_file)
code_text.gsub!(/#if canImport\(SwiftUI\) \&\& canImport\(Combine\)(.|\n)+#endif/,'')
system("rm -rf " + code_file)
aFile = File.new(code_file, 'w+')
aFile.syswrite(code_text)
aFile.close()
