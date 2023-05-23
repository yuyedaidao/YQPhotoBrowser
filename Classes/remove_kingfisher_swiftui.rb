# 解决 xcode13 Kingfisher Release模式下SwiftUI报错问题
puts "<<<-------------------->>>"
dir = Dir.pwd
system("rm -rf Pods/Kingfisher/Sources/SwiftUI")
# files = Dir.entries(dir + "Pods/Kingfisher/Sources")
code_file = dir + "/Pods/Kingfisher/Sources/General/KFOptionsSetter.swift"
if File.exist?(code_file) then
    code_text = File.read(code_file)
    code_text.gsub!(/#if canImport\(SwiftUI\) \&\& canImport\(Combine\)(.|\n)+#endif/,'')
    system("rm -rf " + code_file)
    aFile = File.new(code_file, 'w+')
    aFile.syswrite(code_text)
    aFile.close()
else
    puts "未找到#{code_file}"
end
