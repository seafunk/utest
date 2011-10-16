/* Title: UTest 
modified by Naveen Garg 
changes: removed dependency on lowlevel functions which were brittle.

originally by majkinetor: http://www.autohotkey.com/forum/author-majkinetor.html
forum: http://www.autohotkey.com/forum/viewtopic.php?t=49262

		  Unit testing framework.

		  (see Utest.png)

 Usage:	
		 UTest will scan the script for functions which name starts with "Test_". Test functions have no parameter and use one of the 
		 Assert functions. If Assert function fails, test will fail and you will see that in the result CSV (or in ListView representing that CSV).
		 Result shows the test state, the function name, line number and test name if you have it. 

		 To test your script, use the following template :

		(start code)
			#include UTest.ahk
			return

			Test_MyTest1() {
			}

			Test_MyTest2() {
			}
			...
			...
			#include FunctionToTest.ahk
		(end code)

 Remarks:
		By default, executing the test script will show the GUI with the results. To get the same results in textual form you can set NoGui option and 
		query Result variable from UTest storage:

		>  UTest("NoGUI", true)
		>  #include UTest.ahk
		>  msgbox  UTest("Result")	
		
 CSV:
		Result	- Test result (OK | FAIL).
		Test	- Test function name.
		Line	- Line number of the test.
		Name	- List of names that failed. Name is the Assert user label. Give name to the Assert function if you have multiple Assert functions inside single test.
		Param	- List of parameters which failed (Assert_True, Assert_False)
									       
		Additionally, if you use Gui, tests that failed will be selected and if any of the test failed, complete operation will be marked as failed at the bottom of the gui.
*/									       
#SingleInstance, force							       
									       
UTest("Result", UTest_Start( UTest("NoGui") ))	;execute tests		       
run, output.txt									       
/*									       
 Function: Assert_True 							       
		   Check if conditions are true. 			       
		   All parameters must be expressions except the first one which may be the string representing the test name.
 */
Assert_True(b1="", b2=1, b3=1, b4=1, b5=1, b6=1, b7=1, b8=1, b9=1, b10=1){
Name := b1 + 0 = "" ? b1 : ""
e := {assert: "assert_true"}
stack := object()
loop, 10{
if A_Index == 1
  Continue
if !b%A_Index%
  e.insert("b" A_Index) 
}
if e[1]{
  stack[0] := tostring(Exception(tostring(e)) . tostring(e))
  loop{
  s := exception("level " A_Index, 0 - A_Index)
  if instr(s.What, "runTests")
    break
  s.extra := getLinesNear(s.line, s.file)
  stack[A_Index] := s
  if A_Index > 4
    break
}
  UTest_setFail( Name, "," )
 throw stack
}
}
/*
 Function: Assert_False
 		   Check if conditions are false.
		   All parameters must be expressions except the first one which may be the string representing the test name.
 */
Assert_False( b1="", b2="", b3="", b4="", b5="", b6="", b7="", b8="", b9="", b10="" ) {
	Name := b1 + 0 = "" ? b1 : ""
	loop, 10
		ifNotEqual, b%A_Index%,, ifNotEqual, b%A_Index%, 0
			b := UTest_setFail( Name, A_Index - (bName ? 1 : 0))
	
	if b
		UTest_setFail( Name, "," )
}
/*
 Function:	Assert_Empty 
			Check if variable is empty.
 */
Assert_Empty( Var, Name="" ){
	if (Var != "")
		UTest_setFail( Name )
}
/*
 Function: Assert_NotEmpty 
		   Check if variable is not empty.
 */
Assert_NotEmpty( Var, Name="" ){
	if (Var = "")
		UTest_setFail( Name )
}
/*
 Function: Assert_Contains 
 		   Check if variable contains string.
 */
Assert_Contains(Var, String, Name=""){
	if !InStr(Var, String)
		UTest_setFail( Name )
}

/*
 Function:  Assert_StartsWith
 			Check if variable starts with string.
 */
Assert_StartsWith(Var, String, Name=""){
	if SubStr(Var, 1, Strlen(String)) != String
		UTest_SetFail( Name )
}
/*
 Function: Assert_EndsWith
 		   Check if variable ends with string.
 */
Assert_EndsWith(Var, String, Name=""){
	ifEqual, String,,return
	if SubStr(Var, -1*Strlen(String)+1) != String
		UTest_setFail( Name )
}

/*
 Function: Assert_Match
		   Check if variable content matches RegEx pattern.
 */
Assert_Match(Var, RegEx, Name=""){
	if !RegExMatch(Var, RegEx) 
		UTest_setFail( Name )
}


/*
 Function: UTest_Edit
		   Open editor with given file and go to line number.
		   Required to be implemented by the user in order for double click in GUI to work.
 */
UTest_Edit( Path, LineNumber ) 
{
	Run, "d:\Utils\Edit Plus\EditPlus.exe" "%Path%"
	WinWait, EditPlus
	WinMenuSelectItem,,,Search, Go To, 1&
	Send %LineNumber%{Enter}
}

;===================================================== PRIVATE ======================================


UTest_runTests(){
FileDelete, output.txt
	tests := UTest_GetTests(), bNoGui := UTest("NoGui")
	if  (tests = "") {
		msgbox No tests found !
		ExitApp
	}

	bTestsFail := 0
	loop, parse, tests, `n
	{
		StringSplit, f, A_LoopField, %A_Space%
  try{
		%f1%()		
} catch e{
if !UTest("Name")
  FileAppend % tostring(e) "`n", output.txt
}
  bFail := UTest("F")
  Param := UTest("Param")
  Name := UTest("Name")
  fName := SubStr(f1,6)
		ifEqual, bFail, 1, SetEnv, bTestsFail, 1

		s .= (bFail ? "FAIL" : "OK") "," fName "," f2 "," Name "," Param "`n"
		UTest("F", 0),	UTest("Param", ""), UTest("Name", "")

		if !bNoGui
			LV_Add(bFail ? "Select" : "", bFail ? "FAIL" : "OK", fName, f2, Name, Param)

	}
	if !bNoGui
		LV_ModifyCol(), LV_ModifyCol(1, 100), LV_ModifyCol(3, 50), LV_ModifyCol(4, 150)

	UTest("TestsFail", bTestsFail)
	return SubStr(s, 1, -1)
}

UTest_getTests() {
	s := UTest_GetFunctions()
	loop, parse, s, `n
	{
		if SubStr(A_LoopField, 1, 5)="Test_"
			t .= A_LoopField "`n"
	}
	return SubStr(t, 1, -1)
}
UTest_getFunctions() {
funcs := object()
fnames := ""
FileRead, script, %A_ScriptName%
pos := 1
while pos{
pos := regexmatch(script, "([\w_\d]+)\(", m, pos)
pos += strlen(m1)
f := func(m1)
name := f.name

if !f.name
  Continue

if !f.IsBuiltIn
  funcs[name] := f.name
} 
for i, j in funcs 
{
fnames .= j . "`n"
}
 ; msgbox % fnames
   return SubStr(fNames, 1, -1)
}     

UTest_getFreeGuiNum(){
	loop, 99  {
		Gui %A_Index%:+LastFoundExist
		IfWinNotExist
			return A_Index
	}
	return 0
}

UTest_start( bNoGui = false) {
	if !bNoGui
		hGui := UTest_CreateGui()
	s := UTest_RunTests()
	
	if (hGui){
		Result := UTest("TestsFail") ? "FAIL" : "OK"
		ControlSetText,Static1, %Result%, ahk_id %hGui%
	}
	return s
}

UTest_createGui() {
	w := 500, h := 400
	n := UTest_getFreeGuiNum() 

	Gui, %n%: +LastFound +LabelUTest_
	hGui := WinExist()
	Gui, %n%: Add, ListView, w%w% h%h% gUTest_OnList, Result|Test|Line|Name|Param
	Gui, %n%: Font, s20 bold cRED, Courier New
	Gui, %n%: Add, Text, w%w% h40
	Gui, %n%: Show,autosize, UTest - %A_ScriptName%
	UTest("GUINO", n)

	Hotkey, ifWinActive, ahk_id %hGui%
	Hotkey, ESC, UTest_Close
	Hotkey, ifWinActive
	return hGui

 UTest_Close:
 	ExitApp
 return
}

UTest_setFail(Name="", Param="") {
	UTest("Param", UTest("Param") " " Param)
	UTest("Name",  UTest("Name") " " Name)
	UTest("F", 1 )
	return 1
}

UTest_onList:
	ifNotEqual, A_GuiEvent, DoubleClick, return

	LV_GetText(lineNumber, LV_GetNext(), 3)
	UTest_Edit(A_ScriptFullPath, lineNumber)
return

UTest(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	_ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
return
}


#include util.ahk
