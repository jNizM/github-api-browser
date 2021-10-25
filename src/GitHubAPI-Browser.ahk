; ===========================================================================================================================================================================

/*
	GitHub API Browser (written in AutoHotkey)

	Author ....: jNizM
	Released ..: 2021-10-22
	Modified ..: 2021-10-25
	License ...: MIT
	GitHub ....: https://github.com/jNizM/github-api-browser
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95898
*/


; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-beta.1


; GLOBALS ===================================================================================================================================================================

app := Map("name", "GitHub API Browser", "version", "0.2", "release", "2021-10-25", "author", "jNizM", "licence", "MIT")

hBG := DllCall("gdi32\CreateBitmap", "int", 1, "int", 1, "uint", 0x1, "uint", 32, "int64*", 0x828790, "ptr")
hFG := DllCall("gdi32\CreateBitmap", "int", 1, "int", 1, "uint", 0x1, "uint", 32, "int64*", 0xfbfbfb, "ptr")

GITHUB_USER_API     := "https://api.github.com/users/"
GITHUB_REPOS_API    := "https://api.github.com/repos/"
GITHUB_ACCESS_TOKEN := ""   ; for a higher requests limit per hour


; GUI =======================================================================================================================================================================

Main := Gui(, app["name"])
Main.MarginX := 15
Main.MarginY := 15

Main.SetFont("s20 w600", "Segoe UI")
Main.AddText("xm ym w500 0x200", app["name"])

Main.SetFont("s10 w400", "Segoe UI")
ED01 := Main.AddEdit("xm ym+60 w200")
EM_SETCUEBANNER(ED01, "Enter Username *", true)
ED02 := Main.AddEdit("xm+211 ym+60 w200")
EM_SETCUEBANNER(ED02, "Repository", true)
Main.AddButton("xm+422 yp-1 w80 h27", "Search").OnEvent("Click", Button_Click)

Main.AddPicture("xm   ym+100 w812 h87 BackgroundTrans", "HBITMAP:*" hBG)
Main.AddPicture("xm+1 ym+101 w810 h85 BackgroundTrans", "HBITMAP:*" hFG)

Main.AddText("xm+16 ym+116 w80 h25 0x200 BackgroundFBFBFB", "Name:")
ED03 := Main.AddEdit("x+1 yp w120 0x802 BackgroundFBFBFB")
Main.AddText("xm+266 yp w100 h25 0x200 BackgroundFBFBFB", "Public Repos:")
ED04 := Main.AddEdit("x+1 yp w100 0x802 BackgroundFBFBFB")
Main.AddText("xm+516 yp w100 h25 0x200 BackgroundFBFBFB", "Followers:")
ED05 := Main.AddEdit("x+1 yp w100 0x802 BackgroundFBFBFB")

Main.AddText("xm+16 ym+146 w80 h25 0x200 BackgroundFBFBFB", "Created:")
ED06 := Main.AddEdit("x+1 yp w120 0x802 BackgroundFBFBFB")
Main.AddText("xm+266 yp w100 h25 0x200 BackgroundFBFBFB", "Public Gists:")
ED07 := Main.AddEdit("x+1 yp w100 0x802 BackgroundFBFBFB")
Main.AddText("xm+516 yp w100 h25 0x200 BackgroundFBFBFB", "Following:")
ED08 := Main.AddEdit("x+1 yp w100 0x802 BackgroundFBFBFB")

LB01 := Main.AddListBox("xm ym+196 w200 r24 BackgroundFBFBFB")
LB01.OnEvent("DoubleClick", LB_DoubleClick)

Main.AddPicture("xm+210 ym+196 w292 h283 BackgroundTrans", "HBITMAP:*" hBG)
Main.AddPicture("xm+211 ym+197 w290 h281 BackgroundTrans", "HBITMAP:*" hFG)

Main.AddText("xm+226 ym+212 w100 h25 0x200 BackgroundFBFBFB", "Stars:")
ED09 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+241 w100 h25 0x200 BackgroundFBFBFB", "Watchers:")
ED10 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+270 w100 h25 0x200 BackgroundFBFBFB", "Forks:")
ED11 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+299 w100 h25 0x200 BackgroundFBFBFB", "Downloads:")
ED12 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+328 w100 h25 0x200 BackgroundFBFBFB", "Language:")
ED13 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+357 w100 h25 0x200 BackgroundFBFBFB", "License:")
ED14 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+386 w100 h25 0x200 BackgroundFBFBFB", "Open Issues:")
ED15 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+415 w100 h25 0x200 BackgroundFBFBFB", "Created:")
ED16 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

Main.AddText("xm+226 ym+444 w100 h25 0x200 BackgroundFBFBFB", "Updated:")
ED17 := Main.AddEdit("x+1 yp w160 0x802 BackgroundFBFBFB")

LV01 := Main.AddListView("xm+512 ym+196 w300 h283 BackgroundFBFBFB -LV0x10 LV0x10000", ["Release", "Downloads", "Published"])
LV01.OnEvent("DoubleClick", LV_DoubleClick)

LV02 := Main.AddListView("xm+210 ym+489 w602 h119 BackgroundFBFBFB -LV0x10 LV0x10000", ["Name", "Size", "Uploaded"])

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
	try
	{
		hr := ComObject("WinHttp.WinHttpRequest.5.1")
		hr.Open("GET", GITHUB_USER_API . ED01.Value)
		hr.SetRequestHeader("Content-Type", "application/json")
		if (GITHUB_ACCESS_TOKEN)
			hr.SetRequestHeader("Authorization", GITHUB_ACCESS_TOKEN)
		hr.Send()
		hr.WaitForResponse()

		if (hr.Status = 200)
		{
			json := hr.responseText
			user := Jxon_Load(&json)

			ED03.Value := user["name"]
			ED04.Value := GetNumberFormatEx(repos_count := user["public_repos"])
			ED05.Value := GetNumberFormatEx(user["followers"])
			ED06.Value := SubStr(user["created_at"], 1, -10)
			ED07.Value := GetNumberFormatEx(user["public_gists"])
			ED08.Value := GetNumberFormatEx(user["following"])
			GITHUB_USER_REPOS_API := user["repos_url"]
			per_page := ((repos_count < 30) ? "" : (repos_count > 99) ? "?per_page=100" : "?per_page=" repos_count)
		}
	}


	try
	{
		hr := ComObject("WinHttp.WinHttpRequest.5.1")
		hr.Open("GET", GITHUB_USER_REPOS_API . per_page)
		hr.SetRequestHeader("Content-Type", "application/json")
		if (GITHUB_ACCESS_TOKEN)
			hr.SetRequestHeader("Authorization", GITHUB_ACCESS_TOKEN)
		hr.Send()
		hr.WaitForResponse()

		if (hr.Status = 200)
		{
			json  := hr.responseText
			repos := Jxon_Load(&json)

			LB01_Entries := Array()
			for index, value in repos
				LB01_Entries.Push(repos[index]["name"])

			LB01.Delete()
			LB01.Add(LB01_Entries)
		}
	}

	if (ED02.Value)
		LB_DoubleClick("ED02")
}


LB_DoubleClick(CtrlObj, *)
{
	global releases

	LV01.Opt("-Redraw")
	LV01.Delete()

	try
	{
		hr := ComObject("WinHttp.WinHttpRequest.5.1")
		hr.Open("GET", GITHUB_REPOS_API . ED01.Value . "/" . (CtrlObj = "ED02" ? ED02.Value : LB01.Text))
		hr.SetRequestHeader("Content-Type", "application/json")
		if (GITHUB_ACCESS_TOKEN)
			hr.SetRequestHeader("Authorization", GITHUB_ACCESS_TOKEN)
		hr.Send()
		hr.WaitForResponse()

		if (hr.Status = 200)
		{
			json  := hr.responseText
			repos := Jxon_Load(&json)

			ED09.Value := GetNumberFormatEx(repos["stargazers_count"])
			ED10.Value := GetNumberFormatEx(repos["watchers_count"])
			ED11.Value := GetNumberFormatEx(repos["forks_count"])
			ED13.Value := repos["language"]
			ED14.Value := repos["license"]["spdx_id"]
			ED15.Value := GetNumberFormatEx(repos["open_issues_count"])
			ED16.Value := repos["created_at"]
			ED17.Value := repos["updated_at"]
			GITHUB_RELEASE_API := SubStr(repos["releases_url"], 1, -5)
		}
	}


	try
	{
		hr := ComObject("WinHttp.WinHttpRequest.5.1")
		hr.Open("GET", GITHUB_RELEASE_API . "?per_page=100")
		hr.SetRequestHeader("Content-Type", "application/json")
		if (GITHUB_ACCESS_TOKEN != "")
			hr.SetRequestHeader("Authorization", GITHUB_ACCESS_TOKEN)
		hr.Send()
		hr.WaitForResponse()

		if (hr.Status = 200)
		{
			json     := hr.responseText
			releases := Jxon_Load(&json)

			TotalDownloads := 0
			for index, value in releases
			{
				Downloads := 0
				for dl, v in releases[index]["assets"]
					Downloads += releases[index]["assets"][dl]["download_count"]
				LV01.Add("", releases[index]["tag_name"], GetNumberFormatEx(Downloads), SubStr(releases[index]["published_at"], 1, -10))
				TotalDownloads += Downloads
			}
			ED12.Value := GetNumberFormatEx(TotalDownloads)
		}
	}

	LV01.ModifyCol(1, "AutoHdr")
	LV01.ModifyCol(2, "Integer AutoHdr")
	LV01.ModifyCol(3, "AutoHdr")
	LV01.Opt("+Redraw")
}


LV_DoubleClick(LV, RowNumber)
{
	global releases

	LV02.Opt("-Redraw")
	LV02.Delete()

	try
	{
		for index, value in releases
		{
			if (releases[index]["tag_name"] = LV.GetText(RowNumber))
			{
				for dl, v in releases[index]["assets"]
					LV02.Add("", releases[index]["assets"][dl]["name"], StrFormatByteSizeEx(releases[index]["assets"][dl]["size"]), SubStr(releases[index]["assets"][dl]["updated_at"], 1, -10))
			}
		}
	}

	LV02.ModifyCol(1, "AutoHdr")
	LV02.ModifyCol(2, "Integer AutoHdr")
	LV02.ModifyCol(3, "AutoHdr")
	LV02.Opt("+Redraw")
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


StrFormatByteSizeEx(Value, Flags := 0x2)
{
	Size := VarSetStrCapacity(&NumberStr, 1024)
	if !(DllCall("shlwapi\StrFormatByteSizeEx", "Int64", Value, "Int", Flags, "Str", NumberStr, "Int", Size))
		return NumberStr
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
