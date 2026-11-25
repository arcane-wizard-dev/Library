local _, LIB = ...

if GetLocale() ~= "zhCN" then return end

-- Slash Commands

LIB.SlashHelpLocalization = {
	Percursus = {
		["chat.slash.help"] = "可用命令: %s",
		["chat.slash.unknown"] = "未知命令。输入 %s 打开帮助。",
		["help.button"] = "帮助",
		["settings.help.name"] = "更多信息",
		["help.title"] = "%s – 帮助",
		["help.intro"] = "这里介绍了 %s 的使用方法以及各个聊天命令的作用。点击标题即可展开或收起相应的内容。",
		["help.commands"] = "聊天命令",
		["help.faq"] = "常见问题",
		["help.settings"] = "打开插件选项。",
		["help.changelog"] = "打开更新日志。",
		["help.open"] = "打开此帮助窗口。",
		["changelog.window.title"] = "%s - 更新日志",
		["window.close"] = "关闭"
	}
}
