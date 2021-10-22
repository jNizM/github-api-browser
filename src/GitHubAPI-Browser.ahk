; ===========================================================================================================================================================================

/*
	GitHub API Browser (written in AutoHotkey)

	Author ....: jNizM
	Released ..: 2021-10-22
	Modified ..: 2021-10-22
	License ...: MIT
	GitHub ....: https://github.com/jNizM/github-api-browser
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95898
*/


; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-


; GLOBALS ===================================================================================================================================================================

app := Map("name", "GitHub API Browser", "version", "0.1", "release", "2021-10-22", "author", "jNizM", "licence", "MIT")

hBG := DllCall("gdi32\CreateBitmap", "int", 1, "int", 1, "uint", 0x1, "uint", 32, "int64*", 0x828790, "ptr")
hFG := DllCall("gdi32\CreateBitmap", "int", 1, "int", 1, "uint", 0x1, "uint", 32, "int64*", 0xfbfbfb, "ptr")

GITHUB_USER_API     := "https://api.github.com/users/"
GITHUB_REPOS_API    := "/repos"


; GUI =======================================================================================================================================================================

Main := Gui(, app["name"])
Main.MarginX := 15
Main.MarginY := 15

Main.SetFont("s20 w600", "Segoe UI")
Main.AddText("xm ym w500 0x200", app["name"])

Main.SetFont("s10 w400", "Segoe UI")
ED01 := Main.AddEdit("xm ym+60 w200")
EM_SETCUEBANNER(ED01, "Enter Username", true)
Main.AddButton("x+223 yp-1 w80 h27", "Search").OnEvent("Click", Button_Click)

Main.AddPicture("xm   ym+100 w502 h87 BackgroundTrans", "HBITMAP:*" hBG)
Main.AddPicture("xm+1 ym+101 w500 h85 BackgroundTrans", "HBITMAP:*" hFG)

Main.AddText("xm+16 ym+116 w100 h25 0x200 BackgroundFBFBFB", "Public Repos:")
ED02 := Main.AddEdit("x+1 yp w80 0x802 BackgroundFBFBFB")
Main.AddText("x+108 yp w100 h25 0x200 BackgroundFBFBFB", "Followers:")
ED03 := Main.AddEdit("x+1 yp w80 0x802 BackgroundFBFBFB")

Main.AddText("xm+16 ym+146 w100 h25 0x200 BackgroundFBFBFB", "Public Gists:")
ED04 := Main.AddEdit("x+1 yp w80 0x802 BackgroundFBFBFB")
Main.AddText("x+108 yp w100 h25 0x200 BackgroundFBFBFB", "Following:")
ED05 := Main.AddEdit("x+1 yp w80 0x802 BackgroundFBFBFB")

LB01 := Main.AddListBox("xm ym+200 w200 r15 BackgroundFBFBFB")
LB01.OnEvent("DoubleClick", ListBox_Click)

Main.AddPicture("xm+210 ym+200 w292 h259 BackgroundTrans", "HBITMAP:*" hBG)
Main.AddPicture("xm+211 ym+201 w290 h257 BackgroundTrans", "HBITMAP:*" hFG)

Main.AddText("xm+226 ym+216 w100 h25 0x200 BackgroundFBFBFB", "Stars:")
ED06 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+245 w100 h25 0x200 BackgroundFBFBFB", "Watchers:")
ED07 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+274 w100 h25 0x200 BackgroundFBFBFB", "Forks:")
ED08 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+303 w100 h25 0x200 BackgroundFBFBFB", "Language:")
ED09 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+332 w100 h25 0x200 BackgroundFBFBFB", "License:")
ED10 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+361 w100 h25 0x200 BackgroundFBFBFB", "Open Issues:")
ED11 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+390 w100 h25 0x200 BackgroundFBFBFB", "Created:")
ED12 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+419 w100 h25 0x200 BackgroundFBFBFB", "Updated:")
ED13 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.OnEvent("Close", ExitFunc)
Main.Show()


; WINDOW EVENTS =============================================================================================================================================================

ExitFunc(*)
{
	if (hFG)
		DllCall("gdi32\DeleteObject", "ptr", hFG)
	if (hBG)
		DllCall("gdi32\DeleteObject", "ptr", hBG)
	ExitApp
}


Button_Click(*)
{
	global repos

	try
	{
		hr := ComObject("WinHttp.WinHttpRequest.5.1")
		hr.Open("GET", GITHUB_USER_API . ED01.Value)
		hr.SetRequestHeader("Content-Type", "application/json")
		hr.Send()
		hr.WaitForResponse()

		if (hr.Status = 200)
		{
			json := hr.responseText
			user := Jxon_Load(&json)
			ED02.Value := GetNumberFormatEx(user["public_repos"])
			ED03.Value := GetNumberFormatEx(user["followers"])
			ED04.Value := GetNumberFormatEx(user["public_gists"])
			ED05.Value := GetNumberFormatEx(user["following"])
		}
	}

	try
	{
		hr := ComObject("WinHttp.WinHttpRequest.5.1")
		hr.Open("GET", GITHUB_USER_API . ED01.Value . GITHUB_REPOS_API)
		hr.SetRequestHeader("Content-Type", "application/json")
		hr.Send()
		hr.WaitForResponse()

		if (hr.Status = 200)
		{
			json  := hr.responseText
			repos := Jxon_Load(&json)

			LB_Entries := Array()
			for index, value in repos
				LB_Entries.Push(repos[index]["name"])

			LB01.Delete()
			LB01.Add(LB_Entries)
		}
	}
}


ListBox_Click(*)
{
	global repos

	try
	{
		for index, value in repos
		{
			if (repos[index]["name"] = LB01.Text)
			{
				ED06.Value := GetNumberFormatEx(repos[index]["stargazers_count"])
				ED07.Value := GetNumberFormatEx(repos[index]["watchers_count"])
				ED08.Value := GetNumberFormatEx(repos[index]["forks_count"])
				ED09.Value := repos[index]["language"]
				ED10.Value := repos[index]["license"]["spdx_id"]
				ED11.Value := GetNumberFormatEx(repos[index]["open_issues_count"])
				ED12.Value := repos[index]["created_at"]
				ED13.Value := repos[index]["updated_at"]
			}
		}
	}
}


; FUNCTIONS =================================================================================================================================================================

EM_SETCUEBANNER(handle, string, option := false)
{
	static ECM_FIRST       := 0x1500
	static EM_SETCUEBANNER := ECM_FIRST + 1

	SendMessage(EM_SETCUEBANNER, option, StrPtr(string), handle)
}


GetNumberFormatEx(Value, LocaleName := "!x-sys-default-locale")
{
	if (Size := DllCall("GetNumberFormatEx", "Str", LocaleName, "UInt", 0, "Str", Value, "Ptr", 0, "Ptr", 0, "Int", 0))
	{
		Size := VarSetStrCapacity(&NumberStr, Size)
		if (Size := DllCall("GetNumberFormatEx", "Str", LocaleName, "UInt", 0, "Str", Value, "Ptr", 0, "Str", NumberStr, "Int", Size))
		{
			return SubStr(NumberStr, 1, -3)
		}
	}
	return ""
}


; INCLUDES ==============================================================================================================================================================

Jxon_Load(&src, args*)   ; thx to TheArkive & cocobelgica
{
	static q := Chr(34)

	key    := ""
	is_key := false
	stack  := [tree := []]
	is_arr := Map(tree, 1)
	next   := q "{[01234567890-tfn"
	pos    := 0

	while ((ch := SubStr(src, ++pos, 1)) != "")
	{
		if (InStr(" `t`n`r", ch))
			continue
		if !(InStr(next, ch, true))
		{
			testArr := StrSplit(SubStr(src, 1, pos), "`n")

			ln := testArr.Length
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
				, (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
				: (next == "'")     ? "Unterminated string starting at"
				: (next == "\")     ? "Invalid \escape"
				: (next == ":")     ? "Expecting ':' delimiter"
				: (next == q)       ? "Expecting object key enclosed in double quotes"
				: (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
				: (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
				: (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
				: ["Expecting JSON value(string, number, [true, false, null], object or array)"
				, ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$")-1)][1]
				, ln, col, pos)

			throw Error(msg, -1, ch)
		}

		obj      := stack[1]
		memType  := Type(obj)
		is_array := (memType = "Array") ? 1 : 0

		if (i := InStr("{[", ch))
		{
			val := (i = 1) ? Map() : Array()

			is_array ? obj.Push(val) : obj[key] := val
			stack.InsertAt(1, val)

			is_arr[val] := !(is_key := ch == "{")
			next := q (is_key ? "}" : "{[]0123456789-tfn")
		}
		else if (InStr("}]", ch))
		{
			stack.RemoveAt(1)
			next := stack[1] == tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}
		else if (InStr(",:", ch))
		{
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q "{[0123456789-tfn"
		}
		else
		{
			if (ch == q)
			{
				i := pos
				while (i := InStr(src, q,, i + 1))
				{
					val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
					if (SubStr(val, -1) != "\")
					break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i

				val := StrReplace(val, "\/", "/")
				val := StrReplace(val, "\" . q, q)
				val := StrReplace(val, "\b", "`b")
				val := StrReplace(val, "\f", "`f")
				val := StrReplace(val, "\n", "`n")
				val := StrReplace(val, "\r", "`r")
				val := StrReplace(val, "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1)
				{
					if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, i + 2, 4))
					if (xxxx < 0x100)
						val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
				}

				if (is_key)
				{
					key  := val
					next := ":"
					continue
				}
			}
			else
			{
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos) - pos)

				if (IsInteger(val))
					val += 0
				else if (IsFloat(val))
					val += 0
				else if (val == "true" || val == "false")
					val := (val == "true")
				else if (val == "null")
					val := ""
				else if (is_key)
				{
					pos--
					next := "#"
					continue
				}

				pos += (i - 1)
			}

			is_array ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : is_array ? ",]" : ",}"
		}
	}

	return tree[1]
}

; ===========================================================================================================================================================================
