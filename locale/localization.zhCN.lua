local _, LIB = ...

if GetLocale() ~= "zhCN" then return end

-- Slash Commands

LIB.SlashHelpLocalization = {
	Percursus = {
		["chat.slash.help"] = "可用命令: %s",
		["chat.slash.unknown"] = "未知命令. 输入 %s 查看可用命令."
	}
}
