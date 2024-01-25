import re

def parse_localizable_strings(file_path):
    pattern = re.compile(r'\"(.*?)\"\s*=\s*\"(.*?)\"\s*;')

    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    matches = pattern.findall(content)

    result = {}
    for match in matches:
        key = match[0]
        value = match[1]
        result[key] = value

    return result

def replace_in_swift_file(file_path, pattern, replacement):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    modified_content = re.sub(pattern, replacement, content)

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(modified_content)

# 示例用法
swift_file_path = '/Users/keyon/Desktop/KXProject/KYDebugTool/KYDebugTool/KYDebugTool/Core/Network/Helper/KYErrorHelper.swift'  # 请替换成你的 Swift 文件的路径
# 示例用法
file_path = '/Users/keyon/Downloads/DebugSwift-main/DebugSwift/Resources/en.lproj/Localizable.strings'  # 请替换成你的文件路径
localized_strings = parse_localizable_strings(file_path)

# 打印提取的键值对
for key, value in localized_strings.items():
    replace_in_swift_file(swift_file_path, key, value)
